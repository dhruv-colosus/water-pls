# Release a macOS DMG and Homebrew cask

The app supports Apple silicon and macOS 14+. `VERSION` is the source of truth; this release is **0.1.1**. The supplied droplet is stored in `Assets/AppIcon.png` and converted into the app's multi-resolution ICNS during each build. The DMG embeds the same icon as `.VolumeIcon.icns`, so the mounted installer uses the droplet in Finder. The local DMG file also gets a Finder custom icon; this file metadata may be lost during HTTP downloads, so the unopened downloaded file can still show the standard disk-image icon.

## 1. Build the installer

From the repository root on a Mac with Xcode command-line tools:

```sh
./scripts/package-dmg.sh
open build/WaterPls-v0.1.1-macOS-arm64.dmg
```

Drag `WaterPls.app` onto the Applications shortcut, then open it from Applications. The script builds the native executable, embeds the icon and version, signs the app, creates and verifies a compressed DMG, and generates:

- `build/WaterPls-v0.1.1-macOS-arm64.dmg`
- `build/WaterPls-v0.1.1-macOS-arm64.dmg.sha256`
- `website/public/downloads/WaterPls-v0.1.1-macOS-arm64.dmg`
- `website/src/app/release.json`
- `Casks/water-pls.rb`, with the actual SHA-256 checksum

The website's three download buttons serve the included DMG directly. Deploy the website with the generated public download included. It needs no GitHub release to work. Run `npm run lint` and `npm run build` inside `website` before deploying.

Without a signing identity this is an ad-hoc signed build, **not notarized by Apple**. Downloaded copies may need approval in System Settings → Privacy & Security after the first launch attempt. Homebrew does not bypass Gatekeeper.

### Recommended: Developer ID signing and notarization

Install your **Developer ID Application** certificate and private key from your Apple Developer account. Store notarization credentials interactively once:

```sh
xcrun notarytool store-credentials water-pls-notary
```

Then package with the exact certificate name returned by `security find-identity -v -p codesigning`:

```sh
SIGNING_IDENTITY='Developer ID Application: YOUR NAME (TEAMID)' \
NOTARY_PROFILE='water-pls-notary' \
./scripts/package-dmg.sh
```

This enables the hardened runtime, signs the DMG, submits it to Apple, waits for acceptance, and staples the ticket before calculating the checksum and copying the download to the website. Use the final notarized DMG for both the website and GitHub. Rebuilding or stapling later changes the checksum; regenerate the cask before publishing it.

See [Apple's Developer ID guidance](https://developer.apple.com/developer-id/).

## 2. Upload the DMG to GitHub Releases

Review and commit the source, icon, scripts, cask, release metadata and website download together, then push the commit. Keep the version unique: do not replace the DMG of a version that people have already installed through Homebrew.

Authenticate `gh` with your GitHub account, then run from this repository:

```sh
gh auth login
# After committing and pushing the intended release:
git tag v0.1.1
git push origin v0.1.1
gh release create v0.1.1 \
  build/WaterPls-v0.1.1-macOS-arm64.dmg \
  build/WaterPls-v0.1.1-macOS-arm64.dmg.sha256 \
  --verify-tag \
  --title 'Water, pls 0.1.1' \
  --notes 'Native hydration reminders for Apple silicon, macOS 14+. Open the DMG and drag WaterPls.app into Applications. This build is ad-hoc signed and is not Apple-notarized; macOS may require approval in System Settings > Privacy & Security.'
```

If you notarized the build, replace that release note with its actual signing status. You can also create the release in GitHub's Releases UI and attach these two files. The cask expects the exact versioned DMG filename above.

Verify the published bytes match the cask:

```sh
curl --fail --location \
  https://github.com/dhruv-colosus/water-pls/releases/download/v0.1.1/WaterPls-v0.1.1-macOS-arm64.dmg \
  --output /tmp/WaterPls-release.dmg
shasum -a 256 /tmp/WaterPls-release.dmg
```

Compare with `sha256` in `Casks/water-pls.rb`.

## 3. Publish your own Homebrew tap

Homebrew does not host your app binary: the GitHub Release hosts the DMG, and a tap contains a Ruby cask pointing at it. A personal tap lets users install immediately without waiting for acceptance into Homebrew's official cask repository.

Create the public repository once:

```sh
gh repo create dhruv-colosus/homebrew-tap --public \
  --description 'Homebrew casks by Dhruv'
```

From the `water-pls` repository root, copy the generated cask into a fresh clone and publish it:

```sh
git clone https://github.com/dhruv-colosus/homebrew-tap.git ../homebrew-tap
mkdir -p ../homebrew-tap/Casks
cp Casks/water-pls.rb ../homebrew-tap/Casks/water-pls.rb
git -C ../homebrew-tap add Casks/water-pls.rb
git -C ../homebrew-tap commit -m 'Add Water, pls 0.1.1 cask'
git -C ../homebrew-tap push origin HEAD
```

If the repository already exists, use its existing checkout and pull before updating the cask.

After the release and tap are public, users can install with:

```sh
brew install --cask dhruv-colosus/tap/water-pls
```

Or, for the shorter command:

```sh
brew tap dhruv-colosus/tap
brew install --cask water-pls
```

Verify a real install on an Apple silicon Mac (move aside any manually installed copy first):

```sh
brew audit --cask --online dhruv-colosus/tap/water-pls
brew install --cask dhruv-colosus/tap/water-pls
open /Applications/WaterPls.app
```

Normal uninstall keeps hydration data; `brew uninstall --cask --zap water-pls` also removes preferences and recorded hydration data.

For future releases, increment `VERSION`, package again, publish the new versioned DMG, update the tap with the newly generated cask, and deploy the website with its new download and metadata. Do not advertise the Homebrew command as live until the tap and release have been published and tested.

See the official [tap guide](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap) and [Cask Cookbook](https://docs.brew.sh/Cask-Cookbook). Inclusion in the official `homebrew/cask` repository is a separate reviewed contribution following [Adding Software to Homebrew](https://docs.brew.sh/Adding-Software-to-Homebrew); a personal tap does not automatically add it there.
