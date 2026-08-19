import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

bool get isMobileAdsPlatform {
  if (kIsWeb) return false;
  final binding = WidgetsBinding.instance.runtimeType.toString();
  if (binding.contains('Test')) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}
