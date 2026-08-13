#!/bin/bash
set -e

echo "==> Setting up Flutter SDK"
if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "/tmp/flutter/bin" ]; then
    git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter
  fi
  export PATH="/tmp/flutter/bin:$PATH"
fi
flutter config --no-analytics
flutter --version

echo "==> Installing dependencies"
flutter pub get

echo "==> Building web"
flutter build web --release \
  --dart-define=FIREBASE_WEB_API_KEY="$FIREBASE_WEB_API_KEY" \
  --dart-define=FIREBASE_WEB_APP_ID="$FIREBASE_WEB_APP_ID" \
  --dart-define=FIREBASE_WEB_MEASUREMENT_ID="$FIREBASE_WEB_MEASUREMENT_ID" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_AUTH_DOMAIN="$FIREBASE_AUTH_DOMAIN" \
  --dart-define=FIREBASE_DATABASE_URL="$FIREBASE_DATABASE_URL" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET"
