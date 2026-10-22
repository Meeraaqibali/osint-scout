import os, json
import httpx
from bs4 import BeautifulSoup
from dotenv import load_dotenv
from google import genai

load_dotenv()

GEMINI_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")

_client = None
def _get_client():
    global _client
    if _client is None:
        if not GEMINI_KEY:
            raise RuntimeError("GEMINI_API_KEY missing in .env")
        _client = genai.Client(api_key=GEMINI_KEY)
    return _client

def ddg_search(query: str, max_results: int = 10) -> list[dict]:
    url = "https://html.duckduckgo.com/html/"
    headers = {
        "User-Agent": "Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
        "Accept": "text/html,application/xhtml+xml",
        "Accept-Language": "en-US,en;q=0.9",
    }
    with httpx.Client(timeout=20, follow_redirects=True, headers=headers) as client:
        resp = client.post(url, data={"q": query})
        resp.raise_for_status()

    soup = BeautifulSoup(resp.text, "html.parser")
    results = []
    for node in soup.select(".result"):
        if len(results) >= max_results:
            break
        a = node.select_one("a.result__a")
        snippet = node.select_one(".result__snippet")
        if not a:
            continue
        results.append({
            "title": a.get_text(strip=True),
            "url": a.get("href", ""),
            "snippet": snippet.get_text(strip=True) if snippet else "",
        })
    return results

def _call_gemini(prompt: str) -> dict:
    client = _get_client()
    resp = client.models.generate_content(
        model=GEMINI_MODEL,
        contents=prompt,
        config={"response_mime_type": "application/json", "temperature": 0.3},
    )
    try:
        return json.loads(resp.text)
    except json.JSONDecodeError:
        return {"summary": resp.text, "key_points": [], "entities": [], "risk_notes": None}

def analyze_image_search(image_bytes: bytes, mime_type: str) -> str:
    client = _get_client()
    # Use standard Gemini Vision
    response = client.models.generate_content(
        model=GEMINI_MODEL,
        contents=[
            {"mime_type": mime_type, "data": image_bytes},
            "Describe this image in detail for an OSINT web search. Extract any text, names, locations, or unique identifying features. Keep it under 20 words."
        ]
    )
    return response.text.strip()

def analyze_results(query: str, results: list[dict]) -> dict:
    if not results:
        return {"summary": "No results to analyze.", "key_points": [], "entities": [], "risk_notes": None}
    context = "\n\n".join(f"[{i+1}] {r['title']}\nURL: {r['url']}\n{r['snippet']}" for i, r in enumerate(results))
    prompt = f"""You are an OSINT analyst. Analyze these web results for the query: "{query}"
{context}
Return ONLY valid JSON with this exact shape:
{{
  "summary": "2-3 sentence summary",
  "key_points": ["3-5 short key findings"],
  "entities": ["people, orgs, domains, locations mentioned"],
  "risk_notes": "brief note on reliability/source trust, or null"
}}"""
    return _call_gemini(prompt)

def analyze_text(text: str) -> dict:
    prompt = f"""You are an OSINT analyst. Analyze this text:
\"\"\"{text}\"\"\"
Return ONLY valid JSON:
{{
  "summary": "concise summary",
  "key_points": ["key findings"],
  "entities": ["entities mentioned"],
  "risk_notes": "any reliability signals, or null"
}}"""
    return _call_gemini(prompt)
