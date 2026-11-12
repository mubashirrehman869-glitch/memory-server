@echo off
REM Builds the phone installer: dist\MemorySaver.apk
cd /d "%~dp0"
if not exist mobile\android ( pushd mobile & call flutter create --platforms=android . & popd )
call dart tools\prepare_platforms.dart
pushd mobile
call flutter pub get
call flutter build apk --release || ( echo BUILD FAILED & pause & exit /b 1 )
popd
if not exist dist mkdir dist
copy /y mobile\build\app\outputs\flutter-apk\app-release.apk dist\MemorySaver.apk
echo DONE: dist\MemorySaver.apk  (send to phone, tap to install)
pause
