#!/bin/bash

# Script to build, apply loading screen and deploy to Firebase in one step
echo "🏗️  Starting build and deploy process..."

# Step 1: Build Flutter web app
echo "🛠️  Building Flutter web app..."
flutter build web --release

if [ $? -ne 0 ]; then
  echo "❌ Flutter build failed. Aborting."
  exit 1
fi

# Step 2: Apply custom loading screen
echo "🎨 Applying custom loading screen..."
./apply_loading_screen.sh

if [ $? -ne 0 ]; then
  echo "❌ Failed to apply loading screen. Aborting."
  exit 1
fi

# Step 3: Deploy to Firebase
echo "🚀 Deploying to Firebase..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
  echo "❌ Firebase deployment failed."
  exit 1
fi

echo "✅ Build and deploy completed successfully!"
echo "🌐 App is live at: https://budgetbuddy-asd.web.app" 