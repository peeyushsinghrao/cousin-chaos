#!/usr/bin/env bash
set -e

echo "==> Installing Flutter ${FLUTTER_VERSION}..."
git clone https://github.com/flutter/flutter.git \
  -b stable \
  --depth 1 \
  flutter_sdk

export PATH="$PATH:$(pwd)/flutter_sdk/bin"

echo "==> Flutter version check..."
flutter --version

echo "==> Enabling web support..."
flutter config --enable-web

echo "==> Installing dependencies..."
flutter pub get

echo "==> Building Flutter web (release)..."
flutter build web --release

echo "==> Build complete. Output in build/web/"
