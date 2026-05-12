import 'localization.dart';

extension StringTranslation on String {
  String get t => Localization.instance.translate(this);
}