class AnalysisResult {
  final String filename;
  final double riskScore;
  final double probability;
  final String classification;
  final DiseaseAssociation diseaseAssociation;
  final Map<String, dynamic> details;

  AnalysisResult({
    required this.filename,
    required this.riskScore,
    required this.probability,
    required this.classification,
    required this.diseaseAssociation,
    required this.details,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      filename: json['filename'] ?? 'Live Stream',
      riskScore: (json['risk_score'] ?? 0.0).toDouble(),
      probability: (json['probability'] ?? 0.0).toDouble(),
      classification: json['classification'] ?? 'Unknown',
      diseaseAssociation: DiseaseAssociation.fromJson(
        json['disease_association'] ??
            {'condition': 'N/A', 'confidence': '0%', 'disclaimer': 'No data'},
      ),
      details: json['details'] ?? {},
    );
  }
}

class DiseaseAssociation {
  final String condition;
  final String confidence;
  final String disclaimer;

  DiseaseAssociation({
    required this.condition,
    required this.confidence,
    required this.disclaimer,
  });

  factory DiseaseAssociation.fromJson(Map<String, dynamic> json) {
    return DiseaseAssociation(
      condition: json['condition'],
      confidence: json['confidence'],
      disclaimer: json['disclaimer'],
    );
  }
}
