import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';
import '../models.dart';

class ResultsScreen extends StatelessWidget {
  final SearchResponse response;
  const ResultsScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(response.query)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (response.analysis != null) ...[
            _AnalysisCard(analysis: response.analysis!),
            const SizedBox(height: 20),
          ],
          Text('${response.results.length} SOURCES',
              style: const TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: AppColors.textDim,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...response.results.asMap().entries.map(
                (e) => _ResultCard(index: e.key + 1, result: e.value),
              ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final Analysis analysis;
  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.15), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.auto_awesome, color: AppColors.accent, size: 18),
            SizedBox(width: 8),
            Text('AI ANALYSIS',
                style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Text(analysis.summary,
              style: const TextStyle(fontSize: 14.5, height: 1.5)),
          if (analysis.keyPoints.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...analysis.keyPoints.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 6, right: 8),
                        child: Icon(Icons.circle,
                            size: 6, color: AppColors.accent),
                      ),
                      Expanded(
                        child: Text(p,
                            style: const TextStyle(
                                fontSize: 13.5, height: 1.4)),
                      ),
                    ],
                  ),
                )),
          ],
          if (analysis.entities.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('ENTITIES',
                style: TextStyle(
                    color: AppColors.textDim,
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: analysis.entities
                  .map((e) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(e,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.accent)),
                      ))
                  .toList(),
            ),
          ],
          if (analysis.riskNotes != null &&
              analysis.riskNotes!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warn.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warn.withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 16, color: AppColors.warn),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(analysis.riskNotes!,
                        style: const TextStyle(
                            fontSize: 12.5, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final int index;
  final SearchResult result;
  const _ResultCard({required this.index, required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final uri = Uri.tryParse(result.url);
            if (uri != null) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22, height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$index',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(result.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(result.snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.4, color: AppColors.textDim)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.link, size: 12, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(result.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.accent)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
