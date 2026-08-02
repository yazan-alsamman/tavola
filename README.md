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
        ├── repository/
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

## Networking

This app is a **customer client only**. It does not integrate Platform Admin,
Owner/Organization, Employee/Staff, or health/ops endpoints.

- HTTP client: `dio` via `lib/core/network/api_client.dart`
- Base URL: `AppUrls.apiBaseUrl` (overridable with `--dart-define=API_BASE_URL`)
- Bootstrap in `main.dart`: token store, `AuthRepository`, `AuthSessionController`, `ApiClient`, `LocaleController`
- Feature repositories / screen controllers: route-specific GetX Bindings (lazy, created on navigation)
- **Customer APIs:**
  - Auth: `/auth/customer/*`, `/auth/refresh`
  - Users: `GET/PATCH /users/me`, preferences, avatar, favorites
  - Taxonomy: `GET /cuisine-categories`, `GET /occasion-categories`
  - Restaurants (read): `GET /restaurants`, `GET /restaurants/:id`, gallery, cuisine/occasion categories, working-hours
  - Branches (read): `GET /restaurants/:restaurantId/branches`
  - Tables / floor plans (read, for Select Table): branch tables, floor-plan tables, `GET /tables/:tableId`
  - Reservations: `GET /reservations/availability`, `POST /reservations`, cancel, reschedule
  - Notifications: `GET /notifications`, unread-count, mark read / read-all, identity-token
  - Waitlist: `POST /waitlist`, `POST /waitlist/:entryId/cancel`
- Auth via `SecureAuthTokenStore` + `ApiClient` Bearer interceptor
- Auto refresh via `POST /auth/refresh` before JWT expiry and on `401`
