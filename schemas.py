from pydantic import BaseModel, Field
from typing import Optional

class SearchRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=500)
    analyze: bool = True
    max_results: int = Field(default=10, ge=1, le=30)

class SearchResult(BaseModel):
    title: str
    url: str
    snippet: str

class Analysis(BaseModel):
    summary: str
    key_points: list[str] = []
    entities: list[str] = []
    risk_notes: Optional[str] = None

class SearchResponse(BaseModel):
    query: str
    results: list[SearchResult]
    analysis: Optional[Analysis] = None

class AnalyzeRequest(BaseModel):
    text: str = Field(..., min_length=1, max_length=10000)

class AnalyzeResponse(Analysis):
    pass
