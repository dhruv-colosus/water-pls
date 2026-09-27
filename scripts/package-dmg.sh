#!/bin/zsh
set -euo pipefail
cd "${0:A:h:h}"
if [[ -n "${NOTARY_PROFILE:-}" && -z "${SIGNING_IDENTITY:-}" ]]; then
  echo "NOTARY_PROFILE requires a Developer ID SIGNING_IDENTITY." >&2
  exit 1
fi
./scripts/build.sh
VERSION=$(<VERSION)
FILENAME="Water-pls-${VERSION}.dmg"
DMG="$PWD/build/$FILENAME"
STAGING=$(mktemp -d "$PWD/build/dmg-staging.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto build/WaterPls.app "$STAGING/WaterPls.app"
ln -s /Applications "$STAGING/Applications"
cp build/WaterPls.app/Contents/Resources/AppIcon.icns "$STAGING/.VolumeIcon.icns"
# Finder uses the custom-icon flag on the volume root with .VolumeIcon.icns.
SetFile -a C "$STAGING"
hdiutil create -volname "Water, pls" -srcfolder "$STAGING" -format UDZO -ov "$DMG"
# This custom file icon is local Finder metadata. The embedded volume icon above
# survives web downloads; a DMG's resource fork may not survive HTTP transfer.
swift scripts/set-file-icon.swift Assets/AppIcon.png "$DMG"
if [[ -n "${SIGNING_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "$SIGNING_IDENTITY" "$DMG"
fi
if [[ -n "${NOTARY_PROFILE:-}" ]]; then
  xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
  xcrun stapler staple "$DMG"
  xcrun stapler validate "$DMG"
fi
hdiutil verify "$DMG"
SHA256=$(shasum -a 256 "$DMG" | awk '{print $1}')
mkdir -p website/public/downloads Casks
cp "$DMG" "website/public/downloads/$FILENAME"
printf '%s  %s\n' "$SHA256" "$FILENAME" > "build/$FILENAME.sha256"
cat > website/src/app/release.json <<JSON
{
  "version": "$VERSION",
  "download": "/downloads/$FILENAME",
  "sha256": "$SHA256"
}
JSON
cat > Casks/water-pls.rb <<RUBY
cask "water-pls" do
  version "$VERSION"
  sha256 "$SHA256"

  url "https://github.com/dhruv-colosus/water-pls/releases/download/v#{version}/Water-pls-#{version}.dmg"
  name "Water, pls"
  desc "Native hydration tracker with MacBook notch reminders"
  homepage "https://github.com/dhruv-colosus/water-pls"

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "WaterPls.app"

  zap trash: "~/Library/Preferences/local.water-pls.prototype.plist"
end
RUBY
echo "Packaged $DMG"
echo "SHA-256: $SHA256"
echo "Updated website download and Casks/water-pls.rb. Publish this exact DMG to GitHub before publishing the cask."
