cask "water-pls" do
  version "0.1.1"
  sha256 "7125d662521baea03644690581d8b77cbfdd9fecab507565a7ec52bb7d8a308d"

  url "https://github.com/dhruv-colosus/water-pls/releases/download/v#{version}/WaterPls-v#{version}-macOS-arm64.dmg"
  name "Water, pls"
  desc "Native hydration tracker with MacBook notch reminders"
  homepage "https://github.com/dhruv-colosus/water-pls"

  depends_on arch: :arm64
  depends_on macos: ">= :sonoma"

  app "WaterPls.app"

  zap trash: "~/Library/Preferences/local.water-pls.prototype.plist"
end
