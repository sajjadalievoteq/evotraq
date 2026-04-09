#!/bin/bash

# Build script for TraqTrace Frontend
# Usage: ./build.sh [environment]
# Environments: local, azure, production

ENVIRONMENT=${1:-local}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/build_config.json"

echo "🚀 Building TraqTrace Frontend for environment: $ENVIRONMENT"

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "❌ jq is required for parsing build config. Please install jq."
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Extract configuration for the environment
API_BASE_URL=$(jq -r ".environments.$ENVIRONMENT.API_BASE_URL" "$CONFIG_FILE")
ENV_TYPE=$(jq -r ".environments.$ENVIRONMENT.ENVIRONMENT" "$CONFIG_FILE")

if [ "$API_BASE_URL" == "null" ]; then
    echo "❌ Environment '$ENVIRONMENT' not found in configuration"
    exit 1
fi

echo "📋 Configuration:"
echo "   Environment: $ENVIRONMENT"
echo "   API Base URL: $API_BASE_URL"
echo "   Environment Type: $ENV_TYPE"

# Build the Flutter web app with environment variables
echo "🔨 Building Flutter web application..."
flutter build web \
    --dart-define=API_BASE_URL="$API_BASE_URL" \
    --dart-define=ENVIRONMENT="$ENV_TYPE" \
    --web-renderer html \
    --release

if [ $? -eq 0 ]; then
    echo "✅ Build completed successfully!"
    echo "📁 Build output: ./build/web"
    echo "🌐 API Base URL: $API_BASE_URL"
else
    echo "❌ Build failed!"
    exit 1
fi