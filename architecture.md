# Project Architecture

The project follows the MVC (Model-View-Controller) architecture.

## Models

Models contain the application's data structures.

## Views

Views are responsible for displaying the user interface.

Views should not contain business logic.

## Controllers

Controllers manage business logic and application state using GetX.

Controllers communicate with models and update the UI.

## Project Rules

- Keep business logic inside Controllers.
- Keep UI code inside Views.
- Models should only represent data.
- Create reusable widgets whenever possible.
- One controller per screen when appropriate.
- Organize files by feature.