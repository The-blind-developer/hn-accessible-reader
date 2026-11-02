#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .build dist
app="dist/HN Accessible Reader.app"
mkdir -p "$app/Contents/MacOS"
for arch in arm64 x86_64; do
  /usr/bin/swiftc -O -module-cache-path .build/modules -target "$arch-apple-macos12.0" Reader.swift -o ".build/reader-$arch" -framework Cocoa -framework Carbon
done
/usr/bin/lipo -create .build/reader-arm64 .build/reader-x86_64 -output "$app/Contents/MacOS/HNAccessibleReader"
cp Info.plist "$app/Contents/Info.plist"
/usr/bin/codesign --force --sign - "$app"
/usr/bin/codesign --verify --strict "$app"
/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$app" dist/HN-Accessible-Reader-macOS.zip
printf '%s\n' 'Built dist/HN Accessible Reader.app and dist/HN-Accessible-Reader-macOS.zip'
