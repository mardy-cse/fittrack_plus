#!/bin/bash

# Firebase Phone Authentication Setup Verification Script
# Run this to check all configuration steps

echo "═══════════════════════════════════════════════════════════"
echo "🔍 Firebase Phone Auth Configuration Checker"
echo "═══════════════════════════════════════════════════════════"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check 1: google-services.json exists
echo ""
echo "1️⃣  Checking google-services.json..."
if [ -f "android/app/google-services.json" ]; then
    echo -e "${GREEN}✅ google-services.json found${NC}"
    
    # Check if it contains client_id (indicates proper configuration)
    if grep -q "client_id" android/app/google-services.json; then
        echo -e "${GREEN}✅ google-services.json appears valid${NC}"
    else
        echo -e "${RED}❌ google-services.json may be invalid${NC}"
    fi
else
    echo -e "${RED}❌ google-services.json NOT found${NC}"
    echo "   Download from Firebase Console → Project Settings"
fi

# Check 2: Package name consistency
echo ""
echo "2️⃣  Checking package name consistency..."
PACKAGE_NAME="com.example.fittrack_plus"

# Check in build.gradle.kts
if grep -q "applicationId = \"$PACKAGE_NAME\"" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ Package name in build.gradle.kts: $PACKAGE_NAME${NC}"
else
    echo -e "${YELLOW}⚠️  Check package name in build.gradle.kts${NC}"
fi

# Check in google-services.json
if [ -f "android/app/google-services.json" ]; then
    if grep -q "\"package_name\": \"$PACKAGE_NAME\"" android/app/google-services.json; then
        echo -e "${GREEN}✅ Package name in google-services.json matches${NC}"
    else
        echo -e "${RED}❌ Package name mismatch in google-services.json${NC}"
    fi
fi

# Check 3: AndroidManifest.xml permissions
echo ""
echo "3️⃣  Checking AndroidManifest.xml permissions..."

if grep -q "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ INTERNET permission present${NC}"
else
    echo -e "${RED}❌ INTERNET permission missing${NC}"
fi

if grep -q "android.permission.ACCESS_NETWORK_STATE" android/app/src/main/AndroidManifest.xml; then
    echo -e "${GREEN}✅ ACCESS_NETWORK_STATE permission present${NC}"
else
    echo -e "${YELLOW}⚠️  ACCESS_NETWORK_STATE permission missing${NC}"
fi

# Check 4: Dependencies
echo ""
echo "4️⃣  Checking Firebase dependencies in pubspec.yaml..."

if grep -q "firebase_core:" pubspec.yaml; then
    echo -e "${GREEN}✅ firebase_core dependency found${NC}"
else
    echo -e "${RED}❌ firebase_core dependency missing${NC}"
fi

if grep -q "firebase_auth:" pubspec.yaml; then
    echo -e "${GREEN}✅ firebase_auth dependency found${NC}"
else
    echo -e "${RED}❌ firebase_auth dependency missing${NC}"
fi

# Check 5: Build configuration
echo ""
echo "5️⃣  Checking build configuration..."

if grep -q "com.google.gms.google-services" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ Google Services plugin applied${NC}"
else
    echo -e "${RED}❌ Google Services plugin missing${NC}"
fi

# Check minSdk
if grep -q "minSdk" android/app/build.gradle.kts; then
    echo -e "${GREEN}✅ minSdk configured${NC}"
    echo "   (Firebase Phone Auth requires minSdk 21+)"
else
    echo -e "${YELLOW}⚠️  minSdk not explicitly set${NC}"
fi

# Check 6: SHA Fingerprints
echo ""
echo "6️⃣  Getting current SHA fingerprints..."
echo "   Run this to get your SHA keys:"
echo -e "${YELLOW}   cd android && ./gradlew signingReport${NC}"
echo ""
echo "   Then add them to Firebase Console:"
echo "   Firebase Console → Project Settings → Your Android App"

# Summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 NEXT STEPS:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "1. ✅ Verify all checks above passed"
echo ""
echo "2. 🔑 Add SHA keys to Firebase:"
echo "   cd android"
echo "   ./gradlew signingReport"
echo "   Copy SHA-1 and SHA-256 to Firebase Console"
echo ""
echo "3. ☁️  Enable APIs in Google Cloud Console:"
echo "   https://console.cloud.google.com/apis/library"
echo "   - Android Device Verification API"
echo "   - Play Integrity API"
echo "   - Identity Toolkit API"
echo ""
echo "4. 📱 Enable Phone Auth in Firebase:"
echo "   Firebase Console → Authentication → Sign-in method"
echo "   - Enable Phone provider"
echo "   - Remove any test numbers"
echo ""
echo "5. 🧹 Clean rebuild:"
echo "   flutter clean"
echo "   flutter pub get"
echo "   flutter run"
echo ""
echo "6. 📱 Test on REAL Android device (not emulator)"
echo ""
echo "7. 📝 Check logs for debug messages:"
echo "   Look for: 🔐, 📱, ❌ emoji in console"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "For detailed troubleshooting, see:"
echo "PHONE_AUTH_TROUBLESHOOTING.md"
echo "═══════════════════════════════════════════════════════════"
