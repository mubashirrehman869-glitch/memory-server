@echo off
REM Double-click on a Windows PC that has Flutter + Inno Setup 6 installed.
cd /d "%~dp0"
if not exist desktop\windows ( pushd desktop & call flutter create --platforms=windows . & popd )
call dart tools\prepare_platforms.dart
pushd desktop
call flutter pub get
call flutter build windows --release || ( echo BUILD FAILED & pause & exit /b 1 )
popd
set ISCC="%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if not exist %ISCC% ( echo Install Inno Setup 6 first: https://jrsoftware.org/isdl.php & pause & exit /b 1 )
%ISCC% installer\windows\setup.iss
echo.
echo DONE: dist\MemorySaver-Setup.exe  (copy this one file to any Windows laptop)
pause
