# Restaurant App

Restaurant application built with Flutter using MVC architecture and GetX.

## Tech Stack

- Flutter
- Dart
- GetX
- MVC

## Project Structure

```
lib/
├── app/              # App entry, routes, theme
├── common/           # Shared widgets
├── core/             # Constants, navigation, utilities
└── features/         # Feature modules (MVC per feature)
    └── <feature>/
        ├── controller/
        ├── model/
        ├── view/
        └── widgets/
```

## Development Rules

- No hard coded values — use `AppColors`, `AppStrings`, `AppImages`, `AppTextStyles`, `AppDimensions`.
- Reusable widgets in `common/widgets`.
- Business logic in controllers; UI in views; data in models.
- Feature-based organization.
- Clean and readable code.
- Responsive UI.

See also: `architecture.md`, `cursor.md`, `project_description.md`.
