class Prayer {
  final String id;
  final String title;
  final String originalText;
  final String englishText;
  final List<int> presetCounts;
  final bool isTeleprompter;
  final bool hasTranslation;
  final List<String> originalVerses;
  final List<String> englishVerses;

  const Prayer({
    required this.id,
    required this.title,
    required this.originalText,
    required this.englishText,
    required this.presetCounts,
    required this.isTeleprompter,
    this.hasTranslation = false,
    this.originalVerses = const [],
    this.englishVerses = const [],
  });
}
