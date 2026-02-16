# RESQ-CONNECT Mobile Application - Project Overview

## System Purpose

RESQ-CONNECT is a mobile disaster reporting and citizen concern management system for Filipino local government units. The mobile app enables citizens to report emergencies with automatic GPS tagging, multimedia attachments, and offline SMS capability when internet is unavailable.

---

## Architecture

### Clean Architecture (3 Layers)

**Domain Layer** (Pure Dart - Business Logic)
- Entities: Core business objects (User, Incident, Report)
- Use Cases: Application operations (CreateIncident, LoginUser, VerifyOTP)
- Repository Interfaces: Contracts for data operations

**Data Layer** (Implementation)
- Models: JSON serializable data transfer objects
- Repository Implementations: Bridge between domain and data sources
- Data Sources:
  - Remote: API communication via Dio
  - Local: SQLite, SharedPreferences, SecureStorage

**Presentation Layer** (UI)
- Screens: Full-page views organized by feature
- Widgets: Reusable UI components
- Providers: Riverpod state management

Dependency Flow: `Presentation → Domain ← Data`

---

## Tech Stack

- **Framework**: Flutter/Dart (Android)
- **State Management**: Riverpod
- **HTTP**: Dio with interceptors
- **Maps**: Google Maps Flutter
- **Location**: Geolocator
- **Storage**: SharedPreferences, SQLite, FlutterSecureStorage
- **Notifications**: Firebase Cloud Messaging (FCM)
- **Connectivity**: connectivity_plus
- **Media**: camera, image_picker

---

## Core Functionalities

### 1. Authentication & User Management

**Registration Flow:**
- User provides name, mobile number, email, password
- System sends OTP to email
- User verifies OTP within 5 minutes
- Account created with CITIZEN role

**Login Flow:**
- Email/password authentication
- Returns JWT token stored in secure storage
- Token auto-attached to all API requests via Dio interceptor

**Profile Management:**
- View/update profile information
- Change password
- View notification preferences

### 2. Incident Reporting (Online Mode)

**Report Submission:**
- Automatic GPS coordinate capture
- Select incident type (FIRE, MEDICAL, POLICE, FLOOD, ROAD_ACCIDENT, etc.)
- Add text description (minimum 10 characters)
- Attach photos/videos (max 10s video, max 5 files)
- System generates unique tracking ID
- Immediate acknowledgment notification

**Data Flow:**
1. Capture GPS via LocationService
2. Collect media via CameraService
3. Build incident payload
4. Submit via POST /api/incidents
5. Upload media via POST /api/media/upload
6. Store tracking ID locally
7. Show confirmation screen

### 3. Incident Reporting (Offline/SMS Mode)

**Offline Detection:**
- ConnectivityService monitors network status
- UI switches to offline mode when no internet
- Shows SMS reporting option

**SMS Report Format:**
```
[TYPE] [GPS_COORDINATES] [DETAILS]
Example: FIRE 10.3157,123.8854 House on fire near church
```

**Process:**
1. App detects offline state
2. Gets current GPS coordinates
3. Formats structured SMS message
4. Sends via device SMS to gateway number
5. Backend parses and creates incident
6. User receives acknowledgment SMS with tracking ID

### 4. Report Tracking & History

**My Reports Screen:**
- Fetches user's incidents via GET /api/incidents/my-reports
- Displays in reverse chronological order
- Shows incident type, status, timestamp, location preview
- Real-time updates via Firebase notifications

**Report Details Screen:**
- Full incident information
- Interactive map showing GPS location
- Status timeline (PENDING → ACKNOWLEDGED → IN_PROGRESS → RESOLVED)
- Attached media gallery
- Responder notes (if available)
- Navigation to incident location

**Status Updates:**
- Push notifications (online) via FCM
- SMS notifications (offline/fallback)
- Status badge updates in UI
- Timeline visualization

### 5. Real-Time Notifications

**Push Notifications (FCM):**
- Triggered on status changes
- Background and foreground handling
- Deep linking to incident details
- Token registration on app start

**SMS Fallback:**
- Automatic when push delivery fails
- When user is offline
- Contains tracking ID and status update

**Local Notifications:**
- Displayed when app is in background
- Actionable (tap to view details)
- Managed by NotificationService

---

## Key Services

### LocationService
- Get current GPS coordinates
- Request/check location permissions
- Monitor location changes
- Handle permission denials gracefully

### CameraService
- Capture photos via camera
- Record videos (max 10 seconds)
- Pick from gallery
- Request camera/storage permissions

### ConnectivityService
- Monitor network status (wifi/mobile/none)
- Stream connectivity changes
- Trigger offline mode switch

### SMSService
- Format incident data into structured SMS
- Send SMS via platform channel
- Validate SMS format

### NotificationService
- Initialize FCM
- Request notification permissions
- Display local notifications
- Handle notification taps with deep links
- Manage FCM token lifecycle

### PermissionService
- Centralized permission requests
- Check permission status
- Open app settings if permanently denied
- Handle multiple permissions

### FirebaseService
- FCM initialization
- Token retrieval and refresh
- Message handling (background/foreground)
- Topic subscriptions

## State Management Pattern

### Riverpod Providers

**Authentication State:**
- `authStateProvider` - Current auth status, user, token
- `authNotifierProvider` - Login, logout, register actions

**Incident State:**
- `incidentListProvider` - User's incident list
- `createIncidentProvider` - Submit new incident
- `incidentDetailsProvider(id)` - Fetch specific incident

**Connectivity State:**
- `connectivityProvider` - Stream of network status
- `isOfflineProvider` - Boolean derived state

**Location State:**
- `currentLocationProvider` - Latest GPS coordinates
- `locationPermissionProvider` - Permission status

**Notification State:**
- `fcmTokenProvider` - Firebase token
- `notificationPermissionProvider` - Permission status

### State Lifecycle
1. Provider initialized via `ref.watch()` in UI
2. Provider triggers use case from domain layer
3. Use case calls repository interface
4. Repository implementation fetches from data source
5. Result returned through layers
6. Provider updates state
7. UI rebuilds reactively

---

## Offline Capability Strategy

### Dual Reporting Mode

**Online Mode (Default):**
- Full feature set
- Multimedia support
- Instant API submission
- Real-time status updates

**Offline Mode (Automatic Fallback):**
- SMS-based reporting
- Text and GPS only
- Requires SMS credit
- SMS acknowledgment

### Offline Detection
- Continuous network monitoring via ConnectivityService
- UI shows offline banner when disconnected
- Report screen switches to SMS mode
- Automatically reverts to online when connection restored

### Data Synchronization
- Incidents stored locally in SQLite
- Pending reports queued for submission
- Auto-sync when connection restored
- Conflict resolution via server timestamp

---

## Security Implementation

### Token Management
- JWT stored in FlutterSecureStorage (encrypted)
- Auto-refresh on expiration
- Cleared on logout
- Dio interceptor attaches to all requests

### API Security
- HTTPS only in production
- Certificate pinning (optional)
- Request/response encryption
- Rate limiting handled by backend

### Permission Security
- Runtime permission requests
- Graceful degradation if denied
- No feature breaks on permission denial
- Clear user prompts explaining why permissions needed

### Data Privacy
- No sensitive data in logs (production)
- Media files encrypted at rest
- User location only captured when reporting
- GDPR-compliant data handling

---

## Error Handling

### Network Errors
- Connection timeout → retry with exponential backoff
- No internet → switch to offline mode
- API errors → display user-friendly messages
- 401 Unauthorized → force logout and re-login

### Location Errors
- Permission denied → show permission prompt
- GPS disabled → prompt to enable
- Location unavailable → use last known location
- Timeout → retry or manual location entry

### Media Upload Errors
- File too large → compress before upload
- Upload failed → queue for retry
- Invalid format → show format requirements
- Storage full → clear cache

### Validation Errors
- Client-side validation before API calls
- Server validation errors displayed inline
- Form field highlighting
- Clear error messages

---

## Folder Structure Summary

```
lib/
├── main.dart                        # App entry + FCM background handler
├── injection_container.dart         # Riverpod provider registration
├── core/
│   ├── config/                      # Environment configs (dev/prod)
│   ├── constants/                   # API endpoints, routes, storage keys
│   ├── errors/                      # Custom exceptions, failures
│   ├── network/                     # Dio client, network info
│   ├── theme/                       # App theme, colors, typography
│   └── utils/                       # Validators, formatters, helpers
├── data/
│   ├── datasources/
│   │   ├── local/                   # SQLite, SharedPrefs, SecureStorage
│   │   └── remote/                  # API clients (auth, incidents, media)
│   ├── models/                      # JSON models with serialization
│   └── repositories/                # Repository implementations
├── domain/
│   ├── entities/                    # Business objects
│   ├── params/                      # Use case input parameters
│   ├── repositories/                # Repository interfaces
│   └── usecases/
│       ├── auth/                    # Login, register, verify OTP, logout
│       └── incidents/               # Create, fetch, update incidents
├── presentation/
│   ├── providers/                   # Riverpod providers and notifiers
│   ├── screens/
│   │   ├── auth/                    # Login, register, OTP, forgot password
│   │   ├── home/                    # Main dashboard
│   │   ├── offline/                 # SMS reporting screen
│   │   ├── onboarding/              # First-time user flow
│   │   ├── profile/                 # User profile, settings
│   │   ├── report/                  # Create, view, history, details
│   │   └── splash/                  # Loading screen
│   └── widgets/
│       ├── common/                  # Buttons, inputs, app bar, bottom nav
│       ├── incident/                # Incident cards, type selector, status badge
│       └── map/                     # Location picker, incident map
└── services/
    ├── camera_service.dart          # Photo/video capture
    ├── connectivity_service.dart    # Network monitoring
    ├── firebase_service.dart        # FCM setup
    ├── location_service.dart        # GPS operations
    ├── notification_service.dart    # Push and local notifications
    ├── permission_service.dart      # Permission management
    └── sms_service.dart             # SMS sending
```

---

## Testing Approach

### Unit Tests
- Use case logic validation
- Repository implementations
- Utility functions
- Mock dependencies via Mockito

### Widget Tests
- UI component rendering
- User interaction flows
- Provider state changes
- Mock Riverpod providers

### Integration Tests
- End-to-end user flows
- API integration
- Service interactions
- Real device/emulator testing

# API Endpoints Reference

All endpoints are prefixed with `/api` (or as configured). Unless marked as **Public**, all endpoints require a valid JWT Bearer token in the `Authorization` header.

---

## Authentication

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/auth/register` | Public | Register a new citizen user |
| POST | `/auth/login` | Public | Login and receive JWT token |
| POST | `/auth/verify-otp` | Public | Verify OTP for email/phone verification |
| POST | `/auth/resend-otp` | Public | Resend OTP to the user's contact |
| GET | `/auth/profile` | Bearer | Get the current authenticated user's profile |
| PATCH | `/auth/profile` | Bearer | Update the current authenticated user's profile |
| POST | `/auth/change-password` | Bearer | Change the authenticated user's password |

---

## Incidents

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/incidents` | Citizen | Submit a new incident report |
| GET | `/incidents/my-reports` | Citizen | Get the current user's incident reports |
| POST | `/incidents/:id/feedback` | Citizen | Submit a rating/feedback on a resolved incident |
| GET | `/incidents/assigned` | Responder | Get incidents assigned to the current responder |
| PATCH | `/incidents/:id/status` | Responder | Update the status of an incident (e.g., en route, resolved) |
| POST | `/incidents/:id/response-summary` | Responder | Submit a response summary after resolving an incident |
| GET | `/incidents` | Admin | List all incidents with filters and pagination |
| GET | `/incidents/:id` | Bearer | Get full details of a specific incident |
| PATCH | `/incidents/:id/assign` | Admin | Assign a responder to an incident |
| PATCH | `/incidents/:id/priority` | Admin | Update the priority level of an incident |
| PATCH | `/incidents/:id/type` | Admin | Reclassify the type of an incident |
| GET | `/incidents/:id/timeline` | Admin | Get the full status update timeline of an incident |

---

## Responders

> Requires `Admin` or `Super Admin` role unless noted.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/responders` | Admin | Create a new responder profile |
| GET | `/responders` | Admin | List all responders with filters |
| GET | `/responders/:id` | Admin | Get details of a specific responder |
| PATCH | `/responders/:id` | Admin | Update a responder's profile |
| DELETE | `/responders/:id` | Super Admin | Deactivate a responder |
| GET | `/responders/:id/performance` | Admin | Get performance metrics for a responder |

---

## Users

> Requires `Admin` or `Super Admin` role unless noted.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/users` | Admin | List all users with filters and pagination |
| GET | `/users/:id` | Admin | Get details of a specific user |
| PATCH | `/users/:id` | Admin | Update a user's information |
| DELETE | `/users/:id` | Super Admin | Deactivate a user |
| PATCH | `/users/:id/status` | Admin | Change a user's account status |

---

## Admin

> All endpoints require `Admin` or `Super Admin` role unless noted.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/admin/dashboard` | Admin | Get dashboard statistics and summary metrics |
| GET | `/admin/lgus` | Super Admin | List all Local Government Units (LGUs) |
| POST | `/admin/lgus` | Super Admin | Create a new LGU |
| PATCH | `/admin/lgus/:id` | Super Admin | Update an existing LGU |
| GET | `/admin/system-logs` | Super Admin | View paginated audit/system logs |
| GET | `/admin/system-settings` | Super Admin | Get current system settings |
| PATCH | `/admin/system-settings` | Super Admin | Update (upsert) system settings |

---

## Analytics

> All endpoints require `Admin` or `Super Admin` role.

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/analytics/overview` | Admin | Get a high-level analytics overview |
| GET | `/analytics/response-times` | Admin | Get average response times broken down by agency |
| GET | `/analytics/hotspots` | Admin | Get geographic incident hotspot clusters |
| GET | `/analytics/trends` | Admin | Get incident trends over time |
| GET | `/analytics/by-type` | Admin | Get incident counts grouped by type |
| GET | `/analytics/by-agency` | Admin | Get performance metrics grouped by agency |
| POST | `/analytics/export` | Admin | Export analytics data as a CSV file |

---

## Media

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/media/upload` | Citizen / Responder | Upload a media file (image/video) for an incident. Max 20MB. Supported: jpg, jpeg, png, mp4 |
| GET | `/media/:id` | Bearer | Serve/download a media file |
| DELETE | `/media/:id` | Admin | Delete a media file |

---

## SMS Gateway

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/sms-gateway/webhook` | Public | Receive incoming SMS from external gateway (webhook) |
| POST | `/sms-gateway/send` | Admin | Send an SMS message via the notifications service |
| GET | `/sms-gateway/reports` | Admin | List SMS delivery reports |
| GET | `/sms-gateway/reports/:id` | Admin | Get details of a specific SMS report |

---

## Dev / Testing

> **These endpoints should be removed before production.**

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/dev/sms-test` | Public | Send a test SMS message |

---

## Role Reference

| Role | Access Level |
|------|-------------|
| **Public** | No authentication required |
| **Citizen** | Authenticated citizen users |
| **Responder** | Authenticated responder users |
| **Admin** | Admin or Super Admin |
| **Super Admin** | Super Admin only |
