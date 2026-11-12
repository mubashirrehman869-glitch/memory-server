#!/bin/bash
# Mac: builds dist/MemorySaver.dmg (drag-to-Applications disk image)
set -e; cd "$(dirname "$0")"
[ -d desktop/macos ] || (cd desktop && flutter create --platforms=macos .)
dart tools/prepare_platforms.dart
(cd desktop && flutter pub get && flutter build macos --release)
mkdir -p dist
hdiutil create -volname "Memory Saver" -srcfolder desktop/build/macos/Build/Products/Release/memory_saver_desktop.app -ov -format UDZO dist/MemorySaver.dmg
echo "DONE: dist/MemorySaver.dmg"
