#!/bin/bash
set -e

echo "=========================================="
echo "  Bubble Translate - iOS Build Script"
echo "=========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

APP_NAME="BubbleTranslate"
BUNDLE_ID="com.bubbletranslate.app"
SCHEME="BubbleTranslate"
BUILD_DIR="build"

# Step 1: Check for XcodeGen
echo ""
echo "🔧 Step 1: Generating Xcode project..."
if command -v xcodegen &> /dev/null; then
    xcodegen generate
    echo -e "${GREEN}✅ XcodeGen project created${NC}"
else
    echo -e "${YELLOW}⚠️  XcodeGen not found, trying with existing project...${NC}"
    if [ ! -d "$APP_NAME.xcodeproj" ]; then
        echo -e "${RED}❌ No Xcode project found. Install xcodegen: brew install xcodegen${NC}"
        exit 1
    fi
fi

# Step 2: Verify project exists
echo ""
echo "🔍 Step 2: Verifying project..."
if [ ! -d "$APP_NAME.xcodeproj" ]; then
    echo -e "${RED}❌ $APP_NAME.xcodeproj not found!${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Project found${NC}"

# Step 3: List schemes
echo ""
echo "📋 Step 3: Available schemes..."
xcodebuild -list -project "$APP_NAME.xcodeproj" 2>&1 || true

# Step 4: Build
echo ""
echo "🔨 Step 4: Building $APP_NAME..."
echo "   SDK: iphoneos"
echo "   Arch: arm64"
echo "   Config: Release"

xcodebuild build \
    -project "$APP_NAME.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration Release \
    -sdk iphoneos \
    -arch arm64 \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    DEVELOPMENT_TEAM="" \
    ONLY_ACTIVE_ARCH=NO \
    ENABLE_BITCODE=NO \
    GENERATE_INFOPLIST_FILE=NO \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    2>&1 | tee "$BUILD_DIR/build.log" | tail -30

# Step 5: Check build result
echo ""
echo "🔎 Step 5: Looking for built app..."
APP_PATH=$(find "$BUILD_DIR/DerivedData" -name "$APP_NAME.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ $APP_NAME.app not found in DerivedData!${NC}"
    echo "Build log:"
    cat "$BUILD_DIR/build.log" | grep -i "error:" || true
    exit 1
fi

APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
echo -e "${GREEN}✅ Found app at: $APP_PATH${NC}"
echo "   Size: $APP_SIZE"

# Check that the binary is not empty
BINARY_PATH="$APP_PATH/$APP_NAME"
if [ -f "$BINARY_PATH" ]; then
    BINARY_SIZE=$(stat -f%z "$BINARY_PATH" 2>/dev/null || stat -c%s "$BINARY_PATH" 2>/dev/null || echo "0")
    echo "   Binary size: $BINARY_SIZE bytes"
    if [ "$BINARY_SIZE" -lt 10000 ]; then
        echo -e "${RED}⚠️  Binary is suspiciously small ($BINARY_SIZE bytes). Build may have failed.${NC}"
    fi
else
    echo -e "${RED}❌ Binary not found at $BINARY_PATH${NC}"
    exit 1
fi

# Step 6: Create IPA
echo ""
echo "📱 Step 6: Creating IPA..."
rm -rf "$BUILD_DIR/Payload"
mkdir -p "$BUILD_DIR/Payload"
cp -r "$APP_PATH" "$BUILD_DIR/Payload/"

# Fake sign for jailbroken device
if command -v ldid &> /dev/null; then
    ldid -S "$BUILD_DIR/Payload/$APP_NAME.app/$APP_NAME"
    echo -e "${GREEN}✅ Signed with ldid${NC}"
else
    echo -e "${YELLOW}⚠️  ldid not found, skipping fake signing${NC}"
    echo "   Install with: brew install ldid"
fi

cd "$BUILD_DIR"
zip -r "$APP_NAME.ipa" Payload/ -x "*.DS_Store"
cd "$SCRIPT_DIR"

IPA_PATH="$BUILD_DIR/$APP_NAME.ipa"
if [ -f "$IPA_PATH" ]; then
    IPA_SIZE=$(du -sh "$IPA_PATH" | cut -f1)
    echo ""
    echo "=========================================="
    echo -e "${GREEN}✅ IPA CREATED SUCCESSFULLY!${NC}"
    echo "   Path: $IPA_PATH"
    echo "   Size: $IPA_SIZE"
    echo "=========================================="
else
    echo -e "${RED}❌ Failed to create IPA${NC}"
    exit 1
fi
