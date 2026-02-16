# Resconnect - Emergency Response System

## Prerequisites

- Flutter SDK
- Android Studio (for Android development)
  - Android SDK
  - Android Emulator or physical Android device
- Firebase project (for push notifications)

## Getting Started

### 1. Set up environment variables

```bash
cp .env.example .env
```

Edit `.env` as needed.

### 2. Run the mobile app

#### Step 1: Start an Android emulator

List available emulators:

```bash
emulator -list-avds
```

Start an emulator (replace `<avd_name>` with one from the list above):

```bash
emulator -avd <avd_name>
```

Example:

```bash
emulator -avd Medium_Phone_API_36.1
```

> **Note:** If the `emulator` command is not found, add the Android SDK to your PATH:
> ```bash
> # macOS/Linux - add to ~/.zshrc or ~/.bashrc
> export ANDROID_HOME=$HOME/Library/Android/sdk
> export PATH=$PATH:$ANDROID_HOME/emulator
> export PATH=$PATH:$ANDROID_HOME/platform-tools
> ```

#### Step 2: Run the Flutter app

```bash
flutter pub get
flutter run
```

Verify the emulator is detected:

```bash
flutter devices
```

Or specify a device if multiple are connected:

```bash
flutter run -d <device_id>
```

#### Using a physical device instead

1. Enable Developer Options on your Android device:
   - Go to `Settings > About phone`
   - Tap `Build number` 7 times
2. Enable USB debugging in `Settings > Developer options`
3. Connect your device via USB and accept the debugging prompt
4. Run `flutter devices` to verify it's detected, then `flutter run`

#### Troubleshooting

- Run `flutter doctor` to check your environment setup
- If `emulator` command not found, ensure `$ANDROID_HOME/emulator` is in your PATH
- For physical devices, ensure USB debugging is enabled and the device is authorized

### 3. Generate code (after modifying models/providers)

```bash
dart run build_runner build
```
