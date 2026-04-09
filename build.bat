@echo off
REM Build script for TraqTrace Frontend on Windows
REM Usage: build.bat [environment]
REM Environments: local, azure, production

setlocal enabledelayedexpansion

set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=local

echo 🚀 Building TraqTrace Frontend for environment: %ENVIRONMENT%

REM Get the directory where this script is located
set SCRIPT_DIR=%~dp0
set CONFIG_FILE=%SCRIPT_DIR%build_config.json

echo 📋 Configuration file: %CONFIG_FILE%

REM Parse JSON configuration (simple approach for Windows)
if "%ENVIRONMENT%"=="local" (
    set API_BASE_URL=http://localhost:8080/api
    set ENV_TYPE=development
) else if "%ENVIRONMENT%"=="azure" (
    set API_BASE_URL=https://backend.calmdesert-164bc904.eastus2.azurecontainerapps.io/api
    set ENV_TYPE=production
) else if "%ENVIRONMENT%"=="production" (
    set API_BASE_URL=https://api.traqtrace.com/api
    set ENV_TYPE=production
) else (
    echo ❌ Unknown environment: %ENVIRONMENT%
    echo Available environments: local, azure, production
    exit /b 1
)

echo 📋 Configuration:
echo    Environment: %ENVIRONMENT%
echo    API Base URL: %API_BASE_URL%
echo    Environment Type: %ENV_TYPE%

REM Build the Flutter web app with environment variables
echo 🔨 Building Flutter web application...
flutter build web --dart-define=API_BASE_URL="%API_BASE_URL%" --dart-define=ENVIRONMENT="%ENV_TYPE%" --release

if %errorlevel% equ 0 (
    echo ✅ Build completed successfully!
    echo 📁 Build output: ./build/web
    echo 🌐 API Base URL: %API_BASE_URL%
) else (
    echo ❌ Build failed!
    exit /b 1
)