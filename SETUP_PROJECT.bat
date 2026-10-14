@echo off
where flutter >nul 2>nul
if errorlevel 1 (echo Flutter SDK not found. Install Flutter and add flutter\bin to PATH. & pause & exit /b 1)
flutter create . --platforms=android,web
if errorlevel 1 (pause & exit /b 1)
flutter pub get
if errorlevel 1 (pause & exit /b 1)
echo Setup finished. Run flutter run -d chrome or flutter run on an Android device.
pause
