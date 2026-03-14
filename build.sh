#!/bin/bash
set -e
cd "$(dirname "$0")"
swift build -c release
mkdir -p StandupTimer.app/Contents/MacOS
mkdir -p StandupTimer.app/Contents/Resources
cp .build/release/StandupTimer StandupTimer.app/Contents/MacOS/
cp Info.plist StandupTimer.app/Contents/
cp cat-icon.png StandupTimer.app/Contents/Resources/
cp AppIcon.icns StandupTimer.app/Contents/Resources/
codesign --force --sign - StandupTimer.app
echo "Built StandupTimer.app (ad-hoc signed) — run: open StandupTimer.app"
