# Water, pls

A minimal native macOS proof of concept: a scheduled reminder visually expands from the MacBook notch. SwiftUI draws the interface; an AppKit nonactivating panel presents it without switching away from your current app. No notification banners, external packages, network access, or notification permission required.

## Run

Requires macOS 14+ and Xcode command-line tools with Swift 5.9+.

```sh
./scripts/build.sh
open build/WaterPls.app
```

You can also open `Package.swift` in Xcode. The build script creates an ad-hoc signed local `.app`; it is not notarized for distribution.

## Dashboard and reminders

The native SwiftUI dashboard follows macOS light/dark appearance automatically. It shows today's intake, the remaining daily goal, quick 100/250/500 ml logging, a custom amount popover, and undo for the latest drink. Use **Edit** beside today's total to set an exact total or reset it to zero. The seven-day chart uses blue for intake and pale blue for the remaining goal. Select a day for its exact amount. Empty days stay empty; older entries without a recorded goal do not get a made-up target.

Open **Goal & reminders** with the slider button. Settings, drink history, daily goal snapshots, and measured active time persist locally in UserDefaults. Changing the goal only updates today's target. Existing drink entries are retained.

- **Automatic pacing:** remaining Mac-use hours divided by the number of usual glasses remaining, limited to 15–120 minutes. Defaults are a personal 2,000 ml target, a 250 ml glass, and eight expected hours of Mac use. These are editable preferences, not health recommendations.
- **Fixed interval:** choose 15, 30, 45, 60, 90, or 120 minutes.
- Activity is sampled every 15 seconds while the app runs, using keyboard/mouse idle time. This is an estimate, not access to macOS Screen Time. Reminders pause after two idle minutes, during sleep/lock, and after reaching the goal; returning starts a new interval.
- Logging water recalculates the next reminder. The notch defaults to your usual glass size and also accepts custom amounts from 1–2,000 ml.
- Use **Preview reminder** in settings or the menu-bar droplet to try the notch immediately. Closing the dashboard leaves the app running. Quit from the droplet menu.

## Scope and limitations

- Prefers the display with a physical notch; falls back to a small top-center shape on displays without one.
- Uses a custom black overlay. It does not modify the physical notch or system UI.
- Sleep, session inactivity, and screen lock suppress reminders; waking/unlocking starts a fresh interval.
- No launch-at-login setup, exact clock-time schedules, history editor, or screen-edge mode in this proof of concept.
- Fullscreen apps, Stage Manager, multiple Spaces, and display changes need hands-on verification. Window behavior flags are configured, but the prototype does not promise to overlay every fullscreen/system surface.
- Diagnostic messages report scheduled trigger events and whether presentation preserved the frontmost app. They do not log water entries.

## Verification

Run `swift test` for isolated tests of legacy entry loading, seven-day totals, historical goal preservation, validation/undo, automatic pacing, and settings/activity persistence. Build with `./scripts/build.sh`.

The dashboard and settings were inspected in the running macOS app in system dark mode, including selecting a chart day. Light appearance uses the same semantic system colors; it has not been visually inspected in this session. Fullscreen/Spaces and physical sleep/lock transitions still need hands-on verification.
