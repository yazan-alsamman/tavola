import '../constants/app_strings.dart';

extension ImageSourceX on String {
  bool get isNetworkImage => startsWith(AppStrings.networkImagePrefix);
}
