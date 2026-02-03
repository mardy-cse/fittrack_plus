@echo off
REM Firebase Phone Authentication Setup Verification Script
REM Run this to check all configuration steps

echo ================================================================
echo    Firebase Phone Auth Configuration Checker
echo ================================================================

REM Check 1: google-services.json exists
echo.
echo 1. Checking google-services.json...
if exist "android\app\google-services.json" (
    echo [OK] google-services.json found
    findstr /C:"client_id" android\app\google-services.json >nul
    if %ERRORLEVEL% EQU 0 (
        echo [OK] google-services.json appears valid
    ) else (
        echo [ERROR] google-services.json may be invalid
    )
) else (
    echo [ERROR] google-services.json NOT found
    echo    Download from Firebase Console - Project Settings
)

REM Check 2: Package name
echo.
echo 2. Checking package name...
findstr /C:"applicationId = \"com.example.fittrack_plus\"" android\app\build.gradle.kts >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Package name in build.gradle.kts: com.example.fittrack_plus
) else (
    echo [WARNING] Check package name in build.gradle.kts
)

REM Check 3: AndroidManifest permissions
echo.
echo 3. Checking AndroidManifest.xml permissions...
findstr /C:"android.permission.INTERNET" android\app\src\main\AndroidManifest.xml >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] INTERNET permission present
) else (
    echo [ERROR] INTERNET permission missing
)

findstr /C:"android.permission.ACCESS_NETWORK_STATE" android\app\src\main\AndroidManifest.xml >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] ACCESS_NETWORK_STATE permission present
) else (
    echo [WARNING] ACCESS_NETWORK_STATE permission recommended
)

REM Check 4: Dependencies
echo.
echo 4. Checking Firebase dependencies...
findstr /C:"firebase_core:" pubspec.yaml >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] firebase_core dependency found
) else (
    echo [ERROR] firebase_core dependency missing
)

findstr /C:"firebase_auth:" pubspec.yaml >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] firebase_auth dependency found
) else (
    echo [ERROR] firebase_auth dependency missing
)

REM Check 5: Build configuration
echo.
echo 5. Checking build configuration...
findstr /C:"com.google.gms.google-services" android\app\build.gradle.kts >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Google Services plugin applied
) else (
    echo [ERROR] Google Services plugin missing
)

REM Summary
echo.
echo ================================================================
echo    NEXT STEPS:
echo ================================================================
echo.
echo 1. Verify all checks above passed
echo.
echo 2. Add SHA keys to Firebase:
echo    cd android
echo    gradlew signingReport
echo    Copy SHA-1 and SHA-256 to Firebase Console
echo.
echo 3. Enable APIs in Google Cloud Console:
echo    https://console.cloud.google.com/apis/library
echo    - Android Device Verification API
echo    - Play Integrity API  
echo    - Identity Toolkit API
echo.
echo 4. Enable Phone Auth in Firebase:
echo    Firebase Console - Authentication - Sign-in method
echo    - Enable Phone provider
echo    - Remove any test numbers
echo.
echo 5. Clean rebuild:
echo    flutter clean
echo    flutter pub get
echo    flutter run
echo.
echo 6. Test on REAL Android device (not emulator)
echo.
echo 7. Check logs for debug messages:
echo    Look for emoji in console (phone, lock, X, checkmark)
echo.
echo ================================================================
echo For detailed troubleshooting, see:
echo PHONE_AUTH_TROUBLESHOOTING.md
echo ================================================================
echo.

pause
