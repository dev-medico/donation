#!/bin/bash

# Exit on any error
set -e

# Install Flutter
git clone https://github.com/flutter/flutter.git --depth 1 -b stable flutter
export PATH="$PATH:`pwd`/flutter/bin"

# Check Flutter version and channel
flutter --version

# Get dependencies
flutter pub get

# Build for web
flutter build web --release

# Make sure the output directory exists
echo "Build completed successfully!"
