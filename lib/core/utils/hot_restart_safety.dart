/// LOCKED HOT-RESTART SAFETY — DO NOT MODIFY OR REMOVE.
///
/// Historical root cause:
/// The `google_fonts` package fetched Cormorant Garamond over the network via
/// isolates. Repeated debug Hot Restarts spawned failing isolates and killed
/// the Flutter process.
///
/// Permanent fix (must remain):
/// 1. Brand fonts are bundled locally under `google_fonts/*.ttf`.
/// 2. They are registered in `pubspec.yaml` under `flutter.fonts`.
/// 3. Typography uses `AppFonts` / `AppTextStyles` — NEVER the `google_fonts`
///    package for loading.
/// 4. The `google_fonts` package must stay removed from dependencies.
///
/// Call [apply] at the start of `main()` so this contract stays enforced.
class HotRestartSafety {
  HotRestartSafety._();

  /// Must run first in `main()` after [WidgetsFlutterBinding.ensureInitialized].
  static void apply() {
    // Intentional no-op guard point: fonts are local via pubspec.
    // Do not reintroduce google_fonts runtime fetching here.
  }
}
