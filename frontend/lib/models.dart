class SearchResult {
  final String title;
  final String url;
  final String snippet;
  SearchResult({required this.title, required this.url, required this.snippet});

  factory SearchResult.fromJson(Map<String, dynamic> j) => SearchResult(
        title: j['title'] ?? '',
        url: j['url'] ?? '',
        snippet: j['snippet'] ?? '',
      );
}

class Analysis {
  final String summary;
  final List<String> keyPoints;
  final List<String> entities;
  final String? riskNotes;

  Analysis({
    required this.summary,
    required this.keyPoints,
    required this.entities,
    this.riskNotes,
  });

  factory Analysis.fromJson(Map<String, dynamic> j) => Analysis(
        summary: j['summary'] ?? '',
        keyPoints: List<String>.from(j['key_points'] ?? const []),
        entities: List<String>.from(j['entities'] ?? const []),
        riskNotes: j['risk_notes'] as String?,
      );
}

class SearchResponse {
  final String query;
  final List<SearchResult> results;
  final Analysis? analysis;

  SearchResponse({required this.query, required this.results, this.analysis});

  factory SearchResponse.fromJson(Map<String, dynamic> j) => SearchResponse(
        query: j['query'] ?? '',
        results: (j['results'] as List)
            .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
            .toList(),
        analysis: j['analysis'] != null
            ? Analysis.fromJson(j['analysis'] as Map<String, dynamic>)
            : null,
      );
}
