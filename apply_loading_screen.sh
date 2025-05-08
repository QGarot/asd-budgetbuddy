#!/bin/bash

# Script to add a custom loading screen to index.html after Flutter build
echo "📱 Applying custom loading screen to web build..."

# Path to the index.html file
INDEX_FILE="build/web/index.html"

# Check if the file exists
if [ ! -f "$INDEX_FILE" ]; then
  echo "❌ Error: $INDEX_FILE not found. Run 'flutter build web' first."
  exit 1
fi

# Create a temporary file
TMP_FILE=$(mktemp)

# Add the custom loading screen CSS and HTML
cat > "$TMP_FILE" << 'EOF'
<!DOCTYPE html>
<html>
<head>
  <!--
    If you are serving your web app in a path other than the root, change the
    href value below to reflect the base path you are serving from.

    The path provided below has to start and end with a slash "/" in order for
    it to work correctly.

    For more details:
    * https://developer.mozilla.org/en-US/docs/Web/HTML/Element/base

    This is a placeholder for base href that will be replaced by the value of
    the `--base-href` argument provided to `flutter build`.
  -->
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="A new Flutter project.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="budgetbuddy">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>BudgetBuddy</title>
  <link rel="manifest" href="manifest.json">

  <style>
    body {
      background-color: #7C4DFF; /* Deep Purple Accent (Colors.deepPurpleAccent) */
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      overflow: hidden;
    }

    .loading-container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      opacity: 1;
      transition: opacity 0.5s ease-out;
    }

    .spinner {
      width: 36px;
      height: 36px;
      border: 3px solid rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      border-top-color: white;
      animation: spin 1s linear infinite;
    }

    .message {
      color: white;
      font-family: 'Roboto', sans-serif;
      font-size: 16px;
      margin-top: 16px;
      text-align: center;
      max-width: 280px;
      width: 280px;
      opacity: 0;
      transition: opacity 0.5s ease-in;
      display: none;
      line-height: 1.5;
    }

    @keyframes spin {
      to {
        transform: rotate(360deg);
      }
    }
  </style>
</head>
<body>
  <div id="loading-container" class="loading-container">
    <div id="spinner" class="spinner"></div>
    <div id="timeout-message" class="message">
      Loading takes longer than usual.<br>
      Check your internet connection.
    </div>
  </div>

  <script>
    // Method to hide the loading screen
    function hideLoader() {
      var loadingContainer = document.getElementById('loading-container');
      if (loadingContainer) {
        loadingContainer.style.opacity = '0';
        loadingContainer.style.transition = 'opacity 0.5s ease-out';
        
        setTimeout(function() {
          loadingContainer.style.display = 'none';
        }, 500);
      }
    }

    // Method to show the timeout message
    function showTimeoutMessage() {
      var spinner = document.getElementById('spinner');
      var message = document.getElementById('timeout-message');
      
      if (spinner && message) {
        message.style.display = 'block';
        setTimeout(function() {
          message.style.opacity = '1';
        }, 10);
      }
    }

    // When the page loads
    window.addEventListener('load', function() {
      // Show timeout message after 10 seconds
      var timeoutMessageId = setTimeout(showTimeoutMessage, 10000);
      
      // Check if flutter is already initialized
      if (window.flutterConfiguration) {
        // New way - modern Flutter web bootstrap
        window.addEventListener('flutter-initialized', function() {
          clearTimeout(timeoutMessageId);
          hideLoader();
        });
      } else {
        // Legacy way
        window.addEventListener('flutter-first-frame', function() {
          clearTimeout(timeoutMessageId);
          hideLoader();
        });
      }
    });
  </script>

  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
EOF

# Replace the original file with our modified version
mv "$TMP_FILE" "$INDEX_FILE"

echo "✅ Custom loading screen applied successfully!"
echo "🚀 You can now deploy with 'firebase deploy --only hosting'" 