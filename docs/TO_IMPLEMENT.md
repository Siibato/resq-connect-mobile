# To Implement

Cross-referenced against the server API and the current mobile codebase state.
Items are grouped by feature and ordered by priority/dependency.

---

## 1. Incident Reporting (Online Mode)

**Status:** UI exists (`create_report_screen.dart`) but submission is mocked — no actual API call is made.

### 1.1 Incident Model & DTO

File: `lib/data/models/incident_model.dart` — currently empty.

Implement `IncidentModel` matching the server's `CreateIncidentDto` and response shape:

```dart
class IncidentModel {
  final String? id;
  final String type;         // FIRE | MEDICAL | POLICE
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String? status;      // PENDING | ACKNOWLEDGED | IN_PROGRESS | RESOLVED
  final String? priority;    // LOW | MEDIUM | HIGH | CRITICAL
  final DateTime? createdAt;
  // fromJson / toJson
}
```

### 1.2 Incident Remote Datasource

File: `lib/data/datasources/remote/incident_remote_datasource.dart` — currently empty.

Implement using `DioClient`:

| Method | Endpoint | Usage |
|--------|----------|-------|
| `createIncident(IncidentModel)` | `POST /incidents` | Submit report |
| `getMyReports({page, limit})` | `GET /incidents/my-reports` | Report history |
| `getIncidentDetails(id)` | `GET /incidents/:id` | Report details |
| `submitFeedback(id, rating, feedback?)` | `POST /incidents/:id/feedback` | Rate resolved incident |

### 1.3 Incident Repository Interface + Implementation

- `lib/domain/repositories/incident_repository.dart` — define abstract interface
- `lib/data/repositories/incident_repository_impl.dart` — currently empty, implement interface

### 1.4 Incident Use Cases

All files exist under `lib/domain/usecases/incidents/` but are empty:

| File | Use Case | Calls |
|------|----------|-------|
| `create_incident.dart` | Submit new incident | `incidentRepository.create(params)` |
| `get_user_incidents.dart` | Fetch report history | `incidentRepository.getMyReports(page, limit)` |
| `get_incident_details.dart` | Fetch one report | `incidentRepository.getDetails(id)` |
| `upload_media.dart` | Upload attached media | `POST /media/upload` (multipart) |
| `submit_offline_report.dart` | Queue for SMS/offline sync | Local SQLite + connectivity check |

### 1.5 Incident Provider (State)

File: `lib/presentation/providers/incident_provider.dart` — currently empty.

Replace `report_provider.dart` mock with real Riverpod notifier:

```dart
// Providers needed:
incidentNotifierProvider    // create, loading, success, error states
myReportsProvider           // paginated list of user's reports
incidentDetailsProvider(id) // single incident details
```

### 1.6 Wire Create Report Screen to Real API

In `create_report_screen.dart`:
- Replace `ref.read(reportProvider.notifier).submitReport(report)` with the real `incidentNotifierProvider`
- Pass `type`, `description`, `latitude`, `longitude`, `address` as `CreateIncidentDto`
- After success → upload media files sequentially via `POST /media/upload` with `incidentId`
- Navigate to confirmation screen with returned tracking ID

---

## 2. Media Upload

**Status:** `media_model.dart` is empty. No upload logic exists.

### 2.1 Media Model

```dart
class MediaModel {
  final String id;
  final String incidentId;
  final String fileUrl;
  final String fileType;   // image | video
  final DateTime uploadedAt;
}
```

### 2.2 Media Datasource

New file: `lib/data/datasources/remote/media_remote_datasource.dart`

```dart
Future<MediaModel> uploadMedia(String incidentId, File file);
```

Payload: `multipart/form-data` with fields `file` and `incidentId`. Max 20MB, types: jpg, jpeg, png, mp4.

---

## 3. Report History & Details

**Status:** `report_history_screen.dart` and `report_details_screen.dart` exist but are not wired to API.

- `report_history_screen.dart` → use `myReportsProvider` (see 1.5)
- `report_details_screen.dart` → use `incidentDetailsProvider(id)` (see 1.5)
  - Show status timeline from `GET /incidents/:id/timeline` (admin only — skip for citizen, show `status` field only)
  - Show media gallery from `IncidentMedia` list in incident response
  - Show map marker at `latitude`/`longitude`

---

## 4. Real-time Status Updates (Push Notifications)

**Status:** `firebase_service.dart` and `notification_service.dart` exist but are empty/stub.

### 4.1 Firebase Service

File: `lib/services/firebase_service.dart`

- Initialize FCM on app start
- Get FCM token
- Listen for token refresh
- Handle foreground messages
- Set up background message handler in `main.dart`

### 4.2 Notification Service

File: `lib/services/notification_service.dart`

- Display local notification when FCM message arrives in foreground
- Handle notification tap → deep link to `report_details_screen` with incident ID
- Manage notification permissions via `permission_handler`

### 4.3 FCM Token Registration

After login, send FCM token to backend so it can send push notifications:
- The server's `notifications` module handles this internally — check if there's a `POST /auth/profile` PATCH for device token, or add it to the `UpdateProfileDto` PATCH call on token refresh.

### 4.4 Notification Provider

File: `lib/presentation/providers/notification_provider.dart` — currently empty.

```dart
fcmTokenProvider              // holds current token
notificationPermissionProvider // permission status
```

---

## 5. Offline / SMS Reporting Mode

**Status:** `offline_mode_screen.dart` exists. `sms_service.dart` and `sms_datasource.dart` exist but SMS sending is not implemented.

### 5.1 ConnectivityService

File: `lib/services/connectivity_service.dart` — implement using `connectivity_plus`:

```dart
Stream<bool> get isOfflineStream;
Future<bool> get isOffline;
```

### 5.2 Connectivity Provider

File: `lib/presentation/providers/connectivity_provider.dart` — currently empty.

```dart
connectivityProvider   // Stream<ConnectivityResult>
isOfflineProvider      // bool derived state
```

### 5.3 Offline Banner

File: `lib/presentation/widgets/common/offline_banner.dart` — show when `isOfflineProvider` is true.

### 5.4 SMS Service

File: `lib/services/sms_service.dart`

Format and send structured SMS to the gateway number:

```
[TYPE] [LAT],[LNG] [DESCRIPTION]
Example: FIRE 10.3157,123.8854 House on fire near church
```

Use a platform channel or `sms` package to trigger native SMS sending.

### 5.5 Offline Report Queue (SQLite)

Use case: `submit_offline_report.dart`
- Store pending reports in SQLite when offline
- Auto-sync via `POST /incidents` when connection is restored
- Resolve via `DatabaseHelper`

---

## 6. Authentication — Remaining Gaps

**Status:** Login, Register, and OTP verification are partially implemented but have issues (see recent commits).

### 6.1 Profile Management

- `GET /auth/profile` → populate `profile_screen.dart` with real user data
- `PATCH /auth/profile` → wire `edit_profile_screen.dart` to `UpdateProfileDto`
  - Fields: `firstName`, `lastName`, `mobile`, `address`, `notificationPreference`
- `POST /auth/change-password` → wire `settings_screen.dart`

### 6.2 User Model

File: `lib/data/models/user_model.dart` — verify it maps all fields:
`id`, `email`, `firstName`, `lastName`, `mobile`, `address`, `role`, `notificationPreference`, `isVerified`

---

## 7. Location Provider

**Status:** `location_provider.dart` and `location.dart` entity are empty.

### 7.1 Location Entity

File: `lib/domain/entities/location.dart`

```dart
class Location {
  final double latitude;
  final double longitude;
  final String? address;
}
```

### 7.2 Location Provider

File: `lib/presentation/providers/location_provider.dart`

```dart
currentLocationProvider        // AsyncValue<Position>
locationPermissionProvider     // LocationPermission status
```

---

## 8. Incident Model — Domain Entity

File: `lib/domain/entities/incident.dart` — verify it matches server types:

```dart
class Incident {
  final String id;
  final String type;          // FIRE | MEDICAL | POLICE
  final String description;
  final double latitude;
  final double longitude;
  final String? address;
  final String status;        // PENDING | ACKNOWLEDGED | IN_PROGRESS | RESOLVED
  final String priority;      // LOW | MEDIUM | HIGH | CRITICAL
  final String? responderId;
  final List<Media> media;
  final DateTime createdAt;
}
```

---

## 9. Dependency Injection

File: `lib/injection_container.dart`

Register all new providers/repositories/datasources as they are implemented:
- `IncidentRepository` → `IncidentRepositoryImpl` → `IncidentRemoteDatasource`
- `MediaRemoteDatasource`
- `LocationService`
- `ConnectivityService`
- `NotificationService`
- `FirebaseService`
- `SmsService`

---

## Implementation Order (Suggested)

```
1. IncidentModel + IncidentEntity
2. IncidentRemoteDatasource → IncidentRepository
3. Incident use cases (create, get list, get details)
4. IncidentProvider + wire CreateReportScreen
5. MediaModel + MediaDatasource + upload_media use case
6. ReportHistory + ReportDetails screens wired
7. LocationProvider
8. ConnectivityService + ConnectivityProvider + offline banner
9. SMSService + offline report queue
10. FirebaseService + NotificationService
11. Profile management screens
12. Dependency injection cleanup
```
