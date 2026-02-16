# Folder Structure

This project follows **Clean Architecture** principles, separating concerns into distinct layers.

```
mobile/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── injection_container.dart     # Dependency injection setup
│   │
│   ├── core/                        # Shared utilities and configuration
│   │   ├── config/                  # Environment configuration
│   │   ├── constants/               # App-wide constants (API, routes, storage keys)
│   │   ├── errors/                  # Custom exceptions and failure types
│   │   ├── network/                 # HTTP client (Dio) and network info
│   │   ├── theme/                   # Colors, typography, and app theme
│   │   └── utils/                   # Helper utilities (date, validation, permissions, etc.)
│   │
│   ├── data/                        # Data layer — sources and models
│   │   ├── datasources/
│   │   │   ├── local/               # Local storage (SQLite, SharedPreferences, SecureStorage)
│   │   │   └── remote/              # Remote API datasources (auth, incidents, SMS, user)
│   │   ├── models/                  # JSON serializable data models
│   │   └── repositories/            # Repository implementations (bridge domain ↔ data)
│   │
│   ├── domain/                      # Business logic layer — pure Dart, no dependencies
│   │   ├── entities/                # Core business objects (User, Incident, Report, etc.)
│   │   ├── params/                  # Input parameter objects for use cases
│   │   ├── repositories/            # Repository interfaces (contracts)
│   │   └── usecases/                # Application use cases
│   │       ├── auth/                # Auth use cases (login, register, OTP, logout)
│   │       └── incidents/           # Incident use cases (create, fetch, upload media)
│   │
│   ├── presentation/                # UI layer — screens, providers, widgets
│   │   ├── providers/               # Riverpod state providers and state classes
│   │   ├── screens/                 # Full-page screens organized by feature
│   │   │   ├── auth/                # Login, register, OTP verification, forgot password
│   │   │   ├── home/                # Main home screen
│   │   │   ├── offline/             # Offline mode screen
│   │   │   ├── onboarding/          # Onboarding flow
│   │   │   ├── profile/             # Profile, edit profile, settings
│   │   │   ├── report/              # Create, view, history, confirmation screens
│   │   │   └── splash/              # Splash/loading screen
│   │   └── widgets/                 # Reusable UI components
│   │       ├── common/              # Shared widgets (buttons, text fields, nav bar, etc.)
│   │       ├── incident/            # Incident-specific widgets (cards, badges, media picker)
│   │       └── map/                 # Map-related widgets (location picker, incident map)
│   │
│   └── services/                    # Platform/device services
│       ├── camera_service.dart
│       ├── connectivity_service.dart
│       ├── firebase_service.dart
│       ├── location_service.dart
│       ├── notification_service.dart
│       ├── permission_service.dart
│       └── sms_service.dart
│
├── assets/                          # Static assets (images, fonts, etc.)
├── android/                         # Android-specific configuration
├── ios/                             # iOS-specific configuration
├── test/                            # Unit and widget tests
└── docs/                            # Project documentation
```

## Architecture Overview

The project uses **Clean Architecture** with three main layers:

| Layer | Responsibility |
|---|---|
| **Domain** | Business rules, entities, use case interfaces — no framework dependencies |
| **Data** | API calls, local storage, JSON models, repository implementations |
| **Presentation** | UI rendering, state management (Riverpod), user interaction |

Dependencies flow inward: `Presentation → Domain ← Data`

## Key Technologies

- **State Management**: [Riverpod](https://riverpod.dev/)
- **HTTP Client**: [Dio](https://pub.dev/packages/dio)
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Local Storage**: SharedPreferences + SQLite + FlutterSecureStorage
- **Notifications**: Firebase Messaging
