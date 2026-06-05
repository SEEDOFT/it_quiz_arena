#!/bin/bash

# Script to inject environment variables from .env into iOS Info.plist
# This prevents hardcoding sensitive credentials
# 
# This script runs as a Build Phase in Xcode and substitutes environment 
# variables defined in .env into the Info.plist placeholders

PROJECT_DIR="${PROJECT_DIR:-.}"
INFO_PLIST="${PROJECT_DIR}/ios/Runner/Info.plist"
ENV_FILE="${PROJECT_DIR}/.env"
BUILD_SETTINGS_FILE="${SRCROOT}/../Flutter/Generated.xcconfig"

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Warning: .env file not found at $ENV_FILE"
    exit 0
fi

# Function to read environment variable from .env file
get_env_value() {
    local key=$1
    grep "^${key}=" "$ENV_FILE" | cut -d'=' -f2- | tr -d '\r' | tr -d '"' | tr -d "'"
}

# Read values from .env
IOS_CLIENT_ID=$(get_env_value "GOOGLE_IOS_CLIENT_ID")
IOS_REVERSED_CLIENT_ID=$(get_env_value "GOOGLE_IOS_REVERSED_CLIENT_ID")

# Validate we have the values
if [ -z "$IOS_CLIENT_ID" ] || [ -z "$IOS_REVERSED_CLIENT_ID" ]; then
    echo "Warning: Google iOS credentials not found in .env file"
    echo "  Expected: GOOGLE_IOS_CLIENT_ID and GOOGLE_IOS_REVERSED_CLIENT_ID"
    exit 0
fi

# Create a temporary file to hold the updated plist
TEMP_PLIST="${INFO_PLIST}.tmp"

# Use sed to replace placeholders with actual values
sed -e "s|\$(GOOGLE_IOS_CLIENT_ID)|${IOS_CLIENT_ID}|g" \
    -e "s|\$(GOOGLE_IOS_REVERSED_CLIENT_ID)|${IOS_REVERSED_CLIENT_ID}|g" \
    "$INFO_PLIST" > "$TEMP_PLIST"

# Verify the replacements were made
if grep -q "GOOGLE_IOS_CLIENT_ID\|GOOGLE_IOS_REVERSED_CLIENT_ID" "$TEMP_PLIST"; then
    echo "Error: Failed to substitute all placeholders in Info.plist"
    rm "$TEMP_PLIST"
    exit 1
fi

# Move the temporary file to replace the original
mv "$TEMP_PLIST" "$INFO_PLIST"

# Validate the plist is still valid
if ! plutil -lint "$INFO_PLIST" &>/dev/null; then
    echo "Error: Info.plist is invalid after substitution"
    exit 1
fi

echo "✓ Info.plist updated with Google credentials from .env"
echo "  GIDClientID: ${IOS_CLIENT_ID:0:20}..."
echo "  CFBundleURLScheme: ${IOS_REVERSED_CLIENT_ID:0:20}..."
