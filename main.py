import uvicorn
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware

from schemas import SearchRequest, SearchResponse, SearchResult, Analysis, AnalyzeRequest, AnalyzeResponse
from services import ddg_search, analyze_results, analyze_text, analyze_image_search

app = FastAPI(title="OSINT Scout API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok", "service": "osint-scout"}

@app.post("/api/search", response_model=SearchResponse)
def search(req: SearchRequest):
    try:
        raw = ddg_search(req.query, req.max_results)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Search failed: {e}")

    results = [SearchResult(**r) for r in raw]
    analysis = None
    if req.analyze and results:
        try:
            a = analyze_results(req.query, raw)
            analysis = Analysis(**a)
        except Exception as e:
            print(f"[warn] AI analysis failed: {e}")
    return SearchResponse(query=req.query, results=results, analysis=analysis)

@app.post("/api/search-image", response_model=SearchResponse)
async def search_image(file: UploadFile = File(...)):
    try:
        image_bytes = await file.read()
        query = analyze_image_search(image_bytes)
        print(f"Vision extracted query: {query}")
        
        raw = ddg_search(query, 10)
        results = [SearchResult(**r) for r in raw]
        analysis_data = analyze_results(query, raw)
        
        return SearchResponse(
            query=f"Image: {query}", 
            results=results, 
            analysis=Analysis(**analysis_data)
        )
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Image processing failed: {e}")

@app.post("/api/analyze", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest):
    try:
        return AnalyzeResponse(**analyze_text(req.text))
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"Analysis failed: {e}")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
