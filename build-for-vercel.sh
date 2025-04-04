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

# Build for web with CORS disabled
flutter build web --release --web-renderer html --dart-define=DISABLE_CORS=true

# Generate a web server configuration to disable CORS
cat > build/web/web-server-config.json << EOF
{
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept, Authorization"
  }
}
EOF

# Create a custom index.html wrapper with CSP changes
cp build/web/index.html build/web/index.original.html
cat > build/web/index.html << EOF
<!DOCTYPE html>
<html>
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Red Juniors Blood Donation App">

  <!-- iOS meta tags & icons -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Red Juniors">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- CORS handling -->
  <meta http-equiv="Content-Security-Policy" content="default-src * 'self' data: 'unsafe-inline' 'unsafe-eval' https://redjuniors.mooo.com; connect-src * 'self' https://redjuniors.mooo.com">

  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="manifest" href="manifest.json">
  <script>
    // The value below is injected by flutter build, do not touch.
    var serviceWorkerVersion = null;
  </script>
  <!-- This script adds the flutter initialization JS code -->
  <script src="flutter.js" defer></script>
</head>
<body>
  <script>
    window.addEventListener('load', function(ev) {
      // Download main.dart.js
      _flutter.loader.loadEntrypoint({
        serviceWorker: {
          serviceWorkerVersion: serviceWorkerVersion,
        },
        onEntrypointLoaded: function(engineInitializer) {
          engineInitializer.initializeEngine().then(function(appRunner) {
            appRunner.runApp();
          });
        }
      });
    });
  </script>
</body>
</html>
EOF

# Make sure the output directory exists
echo "Build completed successfully!"
