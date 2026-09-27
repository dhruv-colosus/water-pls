#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
VERSION=$(<VERSION)
[[ "$VERSION" =~ '^[0-9]+\.[0-9]+\.[0-9]+$' ]] || { echo "Invalid VERSION" >&2; exit 1; }
swift build -c release --arch arm64
APP="$PWD/build/WaterPls.app"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources" build/AppIcon.iconset
BIN_DIR=$(swift build -c release --arch arm64 --show-bin-path)
cp "$BIN_DIR/WaterPls" "$APP/Contents/MacOS/WaterPls"
for SIZE in 16 32 128 256 512; do
  sips -z "$SIZE" "$SIZE" Assets/AppIcon.png --out "build/AppIcon.iconset/icon_${SIZE}x${SIZE}.png" >/dev/null
  sips -z "$((SIZE * 2))" "$((SIZE * 2))" Assets/AppIcon.png --out "build/AppIcon.iconset/icon_${SIZE}x${SIZE}@2x.png" >/dev/null
done
iconutil -c icns build/AppIcon.iconset -o "$APP/Contents/Resources/AppIcon.icns"
cat > "$APP/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleExecutable</key><string>WaterPls</string>
<key>CFBundleIdentifier</key><string>local.water-pls.prototype</string>
<key>CFBundleName</key><string>Water, pls</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleShortVersionString</key><string>$VERSION</string>
<key>CFBundleVersion</key><string>$VERSION</string>
<key>CFBundleIconFile</key><string>AppIcon</string>
<key>LSMinimumSystemVersion</key><string>14.0</string>
<key>LSUIElement</key><true/>
<key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign --force --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$APP"
else
  codesign --force --sign - "$APP"
fi
codesign --verify --strict "$APP"
echo "Built $APP"
