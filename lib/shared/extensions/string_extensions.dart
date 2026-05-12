extension StringExtensions on String {
  bool get isNullOrEmpty => isEmpty;
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}