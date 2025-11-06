# junior_flutter_dev_application

## Setup

- Flutter 3.x+ and Dart SDK compatible with environment in `pubspec.yaml`
- Run:
  ```sh
  flutter pub get
  flutter run
  ```

### Brief description of approach

- Architecture: Repository + BLoC pattern.
- Repositories: `lib/repositories/book_repository.dart`, `lib/repositories/favorites_repository.dart`
- State management: BLoC
- API access: `lib/services/api_service.dart`
- UI: Flutter widgets and screens under `lib/ui/`

### Implemented features

- List books by subject (book list screen)
- Book detail screen with description, cover image, authors, subjects, publish year
- Add / remove favorites
- Loading and error states
- Multi-platform project structure (Android, iOS, macOS, Linux, Web)

### Known issues and/or limitations

- No tests
- Some UI edge cases (very long descriptions/subjects) may need better layout handling
- Network errors depend on remote API behavior - offline caching is limited to favorites only

### Time spent on the assignment

10-15 hours
