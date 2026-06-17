#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "==> Cleaning Flutter build artifacts (skipping Xcode)..."
rm -rf build/
rm -rf .dart_tool/
rm -rf android/.gradle/
rm -rf android/app/build/

echo "==> Getting packages..."
flutter pub get

DEVICE_ID=$(flutter devices | grep 'android-arm' | head -1 | sed 's/.*• \([^ ]*\) *•.*/\1/')
if [ -z "$DEVICE_ID" ]; then
  echo "ERROR: No Android device connected."
  exit 1
fi

echo "==> Launching on $DEVICE_ID..."
flutter run -d "$DEVICE_ID" "$@"
