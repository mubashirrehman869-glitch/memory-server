# Memory Saver (Flutter)
memory_saver/
  desktop/   Windows/Mac receiver (Stage 1 done)
  mobile/    Android/iOS app (Stage 2)
## Stage 1 – run the desktop app
1. Install Flutter (https://docs.flutter.dev/get-started/install), then:
   flutter config --enable-windows-desktop --enable-macos-desktop
2. cd desktop && flutter create --platforms=windows,macos . && flutter pub get
3. macOS only: in macos/Runner/*.entitlements add
   com.apple.security.network.server = true, com.apple.security.files.user-selected.read-write = true
4. flutter run -d windows   (or -d macos). Allow the firewall prompt (private networks).
5. Click "Choose Memories folder" -> a QR code appears.
## Test without the phone (curl)
KEY: copy the "k" value from the QR (temporarily print it) then:
  curl -X POST localhost:48484/pair -d '{"key":"KEY","device":"test"}'
  curl -X POST localhost:48484/upload -H "X-Token: TOKEN" -H "X-Filename: a.jpg" \
       -H "X-Created: 2026-11-11T10:00:00" --data-binary @a.jpg
Expect Memories/2026/2026-11-11/Photos/a.jpg. Re-send: status "duplicate".

## Stage 2 – run the mobile app
1. cd mobile && flutter create --platforms=android,ios . && flutter pub get
2. Android: edit android/app/src/main/AndroidManifest.xml
   - above <application> add:
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.CAMERA"/>
       <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
       <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
       <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
   - in <application ...> add: android:usesCleartextTraffic="true"  (temporary until Stage 3 TLS)
   - android/app/build.gradle: minSdk 24 (or flutter.minSdkVersion if >= 24)
3. iOS: ios/Runner/Info.plist add keys NSPhotoLibraryUsageDescription,
   NSCameraUsageDescription, NSLocalNetworkUsageDescription (any text), and under
   NSAppTransportSecurity set NSAllowsLocalNetworking = true. Needs a Mac + Xcode.
4. Phone USB debugging on -> flutter run  (or: flutter build apk --release, then install app-release.apk).
5. Start the desktop app, then tap the QR icon on the phone and scan. Both on the same Wi-Fi.
6. Take a photo -> return to the app -> it appears in Pending.

## Stage 3 – auto-sync + encryption
Run `flutter pub get` again in BOTH desktop/ and mobile/ (new packages).
- Desktop: the QR now carries a fresh 256-bit key (generated per pairing; "New pairing code" makes another).
  Old Stage-2 pairing is invalid: scan the new QR on the phone.
- Phone: Pending items upload automatically (timer 30 s, on app resume, on new photo, and a 15-min
  Android background task). Success -> moves to "Copied" tab with tick + date/time. Originals are untouched.
- Settings (gear icon): Wi-Fi only, Only while charging, Pause backup.
- Remote use: install a VPN such as Tailscale/WireGuard on both devices; the QR already includes every
  laptop IP (including the VPN one) and the file data stays AES-256-GCM encrypted either way.
- Android battery: allow "Unrestricted" battery for the app so the background task isn't killed.

## One-time build -> ready-made installers (no manual steps)
Windows laptop installer:  double-click build_windows.bat  -> dist\MemorySaver-Setup.exe
Android phone installer:   double-click build_android.bat  -> dist\MemorySaver.apk
Mac installer:             ./build_mac.sh                  -> dist/MemorySaver.dmg
Needs once: Flutter SDK; Inno Setup 6 (Windows installer only). The scripts add all permissions automatically.
Using the installers: run MemorySaver-Setup.exe -> it installs, opens the firewall for private Wi-Fi,
adds start-with-Windows, and launches the app. On the phone open MemorySaver.apk (allow "install unknown apps").
iPhone: cannot be installed from a single file; needs a Mac + Xcode (free Apple ID: 7-day installs).

## App flow (final)
Desktop: create password -> press Setup (Documents/Memories + dated folders are created automatically, QR appears)
         -> next launches: password -> dashboard (server runs; "New pairing code" for another phone).
Phone:   create PIN -> press Setup (photo permission + scan laptop QR) -> backup runs automatically.
         -> next launches: PIN -> app. New photos/videos go to Memories/YEAR/DATE/Photos|Videos.
