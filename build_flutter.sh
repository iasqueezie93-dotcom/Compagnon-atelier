#!/usr/bin/env bash
set -euo pipefail
# Run on a workstation with Flutter and Android SDK available.
command -v flutter >/dev/null 2>&1 || { echo 'Flutter SDK manquant : https://docs.flutter.dev/get-started/install'; exit 1; }
BUILD_MODE="${1:---debug}"
case "$BUILD_MODE" in
  --debug|--release) ;;
  *) echo "Usage: bash build_flutter.sh [--debug|--release]"; exit 2 ;;
esac
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="${ROOT}/.flutter_build"
mkdir -p "$WORK"
if [ ! -f "$WORK/pubspec.yaml" ]; then
  flutter create --platforms=android --org fr.compagnon --project-name compagnon_atelier "$WORK"
fi
cp "$ROOT/pubspec.yaml" "$WORK/pubspec.yaml"
rm -rf "$WORK/lib" "$WORK/assets" "$WORK/test"
cp -R "$ROOT/lib" "$WORK/lib"
cp -R "$ROOT/assets" "$WORK/assets"
cp -R "$ROOT/test" "$WORK/test"
mkdir -p "$WORK/android/app/src/main/kotlin/fr/compagnon/compagnon_atelier"
mkdir -p "$WORK/android/app/src/main/res/xml"
cp "$ROOT/android/app/src/main/kotlin/fr/compagnon/compagnon_atelier/MainActivity.kt" "$WORK/android/app/src/main/kotlin/fr/compagnon/compagnon_atelier/MainActivity.kt"
cp "$ROOT/android/app/src/main/res/xml/network_security_config.xml" "$WORK/android/app/src/main/res/xml/network_security_config.xml"
cp "$ROOT/android/app/src/main/AndroidManifest.xml" "$WORK/android/app/src/main/AndroidManifest.xml"
if [ "$BUILD_MODE" = "--debug" ]; then
  (cd "$WORK" && flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings && flutter test && flutter build apk --debug --target-platform android-arm64)
  cp "$WORK/build/app/outputs/flutter-apk/app-debug.apk" "$ROOT/CompagnonAtelier_Reboot_TEST_ARM64.apk"
  echo "APK test créée : $ROOT/CompagnonAtelier_Reboot_TEST_ARM64.apk"
else
  (cd "$WORK" && flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings && flutter test && flutter build apk --release --target-platform android-arm64)
  cp "$WORK/build/app/outputs/flutter-apk/app-release.apk" "$ROOT/CompagnonAtelier_Reboot_RELEASE_ARM64.apk"
  echo "APK de release créée : $ROOT/CompagnonAtelier_Reboot_RELEASE_ARM64.apk"
fi
