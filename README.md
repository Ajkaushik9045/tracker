# NeoShare Tracker Application

A Flutter mobile application serving as the client-facing component of the NeoShare authentication telemetry system. It provides Google authentication and seamlessly logs user lifecycle events to a centralized Firebase backend.

## Features

- **Google Authentication:** Secure sign-in using the official Google Sign-In SDK.
- **Telemetry Logging:** Automatically records `login`, `logout`, and `failed_attempt` events to a Firestore `auth_events` collection.
- **Detailed Error Tracking:** Failed login attempts include specific failure reasons (e.g., `user_cancelled`, `network_error`, `credential_error`) for precise debugging and analytics.
- **Offline Resilience:** Local caching of user session data for faster app startup and state restoration.

## Architecture

This project strictly adheres to **Clean Architecture** principles to ensure maintainability, testability, and separation of concerns:

- **Presentation Layer:** Flutter UI components and State Management using **BLoC** (Business Logic Component).
- **Domain Layer:** Business rules, Entities (`UserEntity`, `AuthEventEntity`), and Use Cases. Abstract repository definitions.
- **Data Layer:** Concrete Repository implementations, Data Models, and Data Sources. The `FirebaseAuthDatasource` is the *only* component that directly interacts with Firebase.

### Key Packages Used
- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `fpdart`: Functional programming constructs (Either, Option) for robust error handling without throwing exceptions.
- `firebase_auth`, `cloud_firestore`, `google_sign_in`: Backend services

## Prerequisites

- Flutter SDK (v3.12.0 or higher)
- A Firebase project configured for Android/iOS/Web
- Google Sign-In enabled in the Firebase Authentication provider settings

## Setup and Installation

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Firebase Configuration:**
   This project uses `flutterfire_cli` for configuration. If you need to reconfigure it for a new project, run:
   ```bash
   flutterfire configure
   ```
   Ensure the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are properly placed in their respective directories.

3. **Run the App:**
   ```bash
   flutter run
   ```

## Testing

Run the comprehensive test suite, which covers domain models, mappers, use cases, and custom failure types:

```bash
flutter test
```
