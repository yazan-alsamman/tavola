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
- Base URL: `https://api.tavola.business/api/v1` via `AppUrls.apiBaseUrl`
  (overridable with `--dart-define=API_BASE_URL`)
- Bootstrap in `main.dart`: token store, `AuthRepository`, `AuthSessionController` (`GuestModeReader`), `ApiClient`, `LocaleController`
- Feature repositories / screen controllers: route-specific GetX Bindings (lazy, created on navigation)
- **Customer APIs wired today:**
  - Auth: `/auth/customer/*`, `/auth/refresh`, `/auth/logout`, `/auth/logout-all`, `/auth/sessions`, `/auth/change-password`
  - Users: `GET/PATCH /users/me`, preferences, avatar, favorites
  - Taxonomy: `GET /cuisine-categories`, `GET /occasion-categories`
  - Discovery: `/discovery/restaurants`, `nearby` (`lat`/`lng`/`radiusKm`), `:id`, branches, floor-plan, offers (Home Special Offer card)
  - Menus (public): `GET /restaurants/:id/menus`, `/menus/default`, `/menus/:menuId`
  - Working hours: `GET /restaurants/:restaurantId/branches/:branchId/working-hours` (primary branch — Details Hours card + restaurant card hours)
  - Tables: `GET /tables/:tableId`
  - Reservations: availability, create, cancel, reschedule, `GET /reservations/my`, `/my/upcoming`, `/my/history`, `/my/:id`
  - Notifications: `GET /notifications`, unread-count, mark read / read-all, identity-token
  - Messaging (Chat tab): `GET/POST /conversations`, `GET /conversations/:id`, messages, read, close
  - Waitlist: `POST /waitlist`, `POST /waitlist/:entryId/cancel`
  - Reviews: `POST /reviews`, `GET /users/me/reviews`, `GET /restaurants/:id/reviews`, `GET /reviews/:id`, `POST /reviews/:id/images`, `DELETE /reviews/:id/images/:imageId`, `DELETE /reviews/:id` (customer-only; owner reply / analytics omitted)
- Auth via `SecureAuthTokenStore` + `ApiClient` Bearer interceptor
- Auto refresh via `POST /auth/refresh` before JWT expiry and on `401`
- **Continue as Guest:** anonymous session — no Bearer, no `/auth/refresh`, no authenticated APIs until login
- **Startup session mode:** `SessionMode` (`none` / `guest` / `authenticated`) persisted via auth-feature `SessionModePreferences` (SharedPreferences). Login awaits mode persist and schedules Keychain token persist immediately (non-blocking). `SplashController.resolveDestination()` hydrates the token store before routing and restores Home for guest or authenticated sessions; Welcome only on first launch or after Logout
- **Profile Log out:** best-effort `POST /auth/logout` (Bearer) via `AuthRepository`, then local token/SessionMode clear → Welcome. Remote failure never blocks local logout
