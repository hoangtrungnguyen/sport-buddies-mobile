# Running Flutter on Android

## Prerequisites

### 1. Android SDK (cmdline-tools)

The Homebrew `android-platform-tools` cask only provides `platform-tools` — it does **not** include `sdkmanager` or NDK. Install the full SDK:

```bash
# Download cmdline-tools
curl -o /tmp/cmdline-tools.zip "https://dl.google.com/android/repository/commandlinetools-mac-11076708_latest.zip"

# Set up SDK dir
mkdir -p ~/Library/Android/sdk/cmdline-tools/latest
unzip /tmp/cmdline-tools.zip -d /tmp/cmdtools
mv /tmp/cmdtools/cmdline-tools/* ~/Library/Android/sdk/cmdline-tools/latest/

# Add to ~/.zshrc
export ANDROID_HOME=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools

# Point Flutter at the SDK
flutter config --android-sdk ~/Library/Android/sdk
```

> Alternatively, install **Android Studio** — it bundles everything automatically.

### 2. Accept SDK licenses

```bash
yes | flutter doctor --android-licenses
```

### 3. Verify

```bash
flutter doctor
```

All Android toolchain items should be green.

---

## Run on device

```bash
flutter run -d "SM A066B"
# or list available devices first:
flutter devices
```

---

## Common build errors & fixes

### `Unresolved reference: util` in build.gradle.kts

Add explicit import at the top of `android/app/build.gradle.kts`:

```kotlin
import java.util.Properties
```

Then use `Properties()` instead of `java.util.Properties()`.

### NDK license not accepted

```bash
yes | flutter doctor --android-licenses
```

### Kotlin version incompatible with dependencies

In `android/settings.gradle.kts`, bump the Kotlin plugin version:

```kotlin
id("org.jetbrains.kotlin.android") version "2.3.10" apply false
```

### `kotlinOptions { jvmTarget }` is an error (Kotlin 2.3+)

Replace the old `kotlinOptions` block in `android/app/build.gradle.kts` with the new DSL outside the `android` block:

```kotlin
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11
    }
}
```

### Dart SDK constraint too old for json_serializable

In `pubspec.yaml`:

```yaml
environment:
  sdk: ^3.8.0
```

### CMake auto-install on first build

First build downloads CMake 3.22.1 automatically — takes 2–5 min, not an error.
