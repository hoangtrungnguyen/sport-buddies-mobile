// TODO: regenerate via flutterfire configure once Firebase project exists.
//
// This file is a hand-written stub shipped in grava-35d5.9 so that
// `main.dart` (grava-35d5.4) can call
// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
// without a compile error before:
//   1. `firebase_core` is added to pubspec.yaml (grava-35d5.3), and
//   2. a real Firebase project is configured for SportBuddies.
//
// Once the real Firebase project exists, run:
//     flutterfire configure --project=<sportbuddies-project-id>
// which will overwrite this file with the canonical generated form
// (including the `package:firebase_core/firebase_core.dart` import and
// platform-specific options). At that point the local `FirebaseOptions`
// class below must be removed in favour of the real one from
// `firebase_core`.

/// Placeholder mirror of `firebase_core`'s `FirebaseOptions`.
///
/// We define it locally because `firebase_core` is not yet a dependency
/// of this app (added in grava-35d5.3). The shape matches the real one's
/// required-named-parameter surface so calling code does not need to
/// change when this stub is replaced.
class FirebaseOptions {
  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.databaseURL,
    this.storageBucket,
    this.measurementId,
    this.trackingId,
    this.deepLinkURLScheme,
    this.androidClientId,
    this.iosClientId,
    this.iosBundleId,
    this.appGroupId,
  });

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? authDomain;
  final String? databaseURL;
  final String? storageBucket;
  final String? measurementId;
  final String? trackingId;
  final String? deepLinkURLScheme;
  final String? androidClientId;
  final String? iosClientId;
  final String? iosBundleId;
  final String? appGroupId;
}

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Stub shape mirrors what `flutterfire configure` produces so the
/// call-site in `main.dart` will compile both now and after the file
/// is regenerated.
class DefaultFirebaseOptions {
  // Stub returns a single placeholder for every platform. The real
  // generated file branches on `defaultTargetPlatform`; we don't yet,
  // because that would require importing `package:flutter/foundation.dart`
  // for the enum, which is fine — but the stub deliberately keeps the
  // surface minimal so the file compiles even if Flutter isn't fully
  // wired (e.g. during the very-early bootstrap of grava-35d5.4).
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'TODO-firebase-api-key',
        appId: 'TODO-firebase-app-id',
        messagingSenderId: 'TODO-firebase-sender-id',
        projectId: 'TODO-firebase-project-id',
        storageBucket: 'TODO-firebase-storage-bucket',
        authDomain: 'TODO-firebase-auth-domain',
      );
}
