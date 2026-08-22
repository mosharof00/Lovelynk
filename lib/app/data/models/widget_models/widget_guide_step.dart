class WidgetGuideStep {
  const WidgetGuideStep({
    required this.imagePath,
    required this.title,
    this.subtitle,
    this.helpLabel,
    this.helpMessage,
  });

  final String imagePath;
  final String title;
  final String? subtitle;
  final String? helpLabel;
  final String? helpMessage;
}
