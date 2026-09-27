import AppKit
import SwiftUI

// A nonactivating panel leaves the frontmost application's keyboard focus alone.
final class ReminderPanel: NSPanel {
    var onMouseInteraction: (() -> Void)?

    override func sendEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown, .rightMouseDown, .otherMouseDown:
            onMouseInteraction?()
        default:
            break
        }
        super.sendEvent(event)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

// Vector geometry matches Assets/water-glass.svg; native paths stay crisp at notch size.
struct WaterGlass: View {
    var outlineColor: Color = .white.opacity(0.9)

    var body: some View {
        GeometryReader { geometry in
            let scale = geometry.size.width / 72
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 17, y: 26))
                    p.addCurve(to: CGPoint(x: 56, y: 29), control1: CGPoint(x: 30, y: 17), control2: CGPoint(x: 39, y: 37))
                    p.addLine(to: CGPoint(x: 53, y: 59))
                    p.addQuadCurve(to: CGPoint(x: 46, y: 65), control: CGPoint(x: 53, y: 65))
                    p.addLine(to: CGPoint(x: 26, y: 65))
                    p.addQuadCurve(to: CGPoint(x: 19, y: 59), control: CGPoint(x: 19, y: 65))
                    p.closeSubpath()
                }.fill(.cyan.opacity(0.24))
                Path { p in
                    p.move(to: CGPoint(x: 17, y: 26))
                    p.addCurve(to: CGPoint(x: 56, y: 29), control1: CGPoint(x: 30, y: 17), control2: CGPoint(x: 39, y: 37))
                }.stroke(.cyan, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                Path { p in
                    p.move(to: CGPoint(x: 22, y: 7))
                    p.addLine(to: CGPoint(x: 50, y: 7))
                    p.addQuadCurve(to: CGPoint(x: 58, y: 14), control: CGPoint(x: 58, y: 7))
                    p.addLine(to: CGPoint(x: 54, y: 59))
                    p.addQuadCurve(to: CGPoint(x: 46, y: 66), control: CGPoint(x: 54, y: 66))
                    p.addLine(to: CGPoint(x: 26, y: 66))
                    p.addQuadCurve(to: CGPoint(x: 18, y: 59), control: CGPoint(x: 18, y: 66))
                    p.addLine(to: CGPoint(x: 14, y: 14))
                    p.addQuadCurve(to: CGPoint(x: 22, y: 7), control: CGPoint(x: 14, y: 7))
                    p.closeSubpath()
                }.stroke(outlineColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            }.frame(width: 72, height: 72).scaleEffect(scale, anchor: .topLeading)
        }.accessibilityHidden(true)
    }
}

struct NotchView: View {
    @ObservedObject var model: Hydration
    let notchWidth: CGFloat
    let topInset: CGFloat
    var onHoverChanged: (Bool) -> Void
    @State private var selectedAmount = 250
    @State private var custom = ""
    @State private var editingCustom = false
    @State private var loggedAmount = 250
    @FocusState private var customFocused: Bool
    private var amount: Int? {
        if !editingCustom { return selectedAmount }
        guard let value = Int(custom), (1...2000).contains(value) else { return nil }
        return value
    }
    private func logAmount() {
        guard !model.confirmation, let amount else { return }
        loggedAmount = amount
        model.log(amount)
        customFocused = false
        withAnimation(reduceMotion ? .easeOut(duration: 0.18) : .smooth(duration: 0.55)) {
            editingCustom = false
            model.confirmation = true
        }
        model.onEditingAmount?(false)
    }
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Color.clear.frame(height: topInset)
            if model.expanded {
                ZStack {
                    if model.confirmation {
                        SipConfirmation(amount: loggedAmount)
                            .transition(sipTransition)
                    } else {
                        reminderContent
                            .transition(sipTransition)
                    }
                }
                .padding(.horizontal, 22).padding(.top, 14).padding(.bottom, 14)
                .transition(.opacity.combined(with: .offset(y: -8)))
            }
        }
        .frame(width: model.expanded ? 420 : notchWidth)
        .background(.black, in: UnevenRoundedRectangle(bottomLeadingRadius: model.expanded ? 28 : 10, bottomTrailingRadius: model.expanded ? 28 : 10))
        .foregroundStyle(.white)
        .onHover(perform: onHoverChanged)
        .animation(reduceMotion ? .easeOut(duration: 0.15) : .spring(response: 0.48, dampingFraction: 0.84), value: model.expanded)
        .frame(width: 460, height: 320, alignment: .top)
        .onAppear { selectedAmount = model.preferences.serving }
        .preferredColorScheme(.dark)
    }

    private var sipTransition: AnyTransition {
        reduceMotion ? .opacity : .modifier(
            active: SipDissolve(blur: 9, opacity: 0, scale: 0.97),
            identity: SipDissolve(blur: 0, opacity: 1, scale: 1))
    }

    private var reminderContent: some View {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 13) {
                        WaterGlass().frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.reminderMessage)
                                .font(.system(size: 17, weight: .semibold))
                            Text("\(model.today) ml logged today")
                                .font(.system(size: 12)).foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer(minLength: 0)

                    }
                    HStack(spacing: 10) {
                        Button(action: logAmount) {
                            Label(amount.map { "Drank \($0) ml" } ?? "Enter amount", systemImage: "checkmark")
                                .font(.system(size: 13, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 11)
                                .foregroundStyle(.black).background(.cyan.opacity(amount == nil ? 0.4 : 1), in: Capsule())
                        }.buttonStyle(.plain).disabled(model.confirmation || amount == nil)
                        Button("Later") { model.onDismiss?() }
                            .font(.system(size: 13, weight: .medium)).buttonStyle(.plain)
                            .padding(.horizontal, 18).padding(.vertical, 11)
                            .background(.white.opacity(0.1), in: Capsule())
                    }
                    if !model.confirmation {
                        HStack(spacing: 6) {
                            ForEach([100, 250, 500], id: \.self) { value in
                                Button {
                                    selectedAmount = value
                                    if editingCustom { model.onEditingAmount?(false) }
                                    editingCustom = false
                                    customFocused = false
                                } label: {
                                    Text("\(value) ml")
                                        .foregroundStyle(!editingCustom && selectedAmount == value ? Color.cyan : .white.opacity(0.55))
                                        .padding(.horizontal, 10).padding(.vertical, 4)
                                        .background(.white.opacity(!editingCustom && selectedAmount == value ? 0.1 : 0), in: Capsule())
                                }.buttonStyle(.plain)
                                    .accessibilityAddTraits(!editingCustom && selectedAmount == value ? .isSelected : [])
                            }
                            Spacer(minLength: 0)
                            Button {
                                editingCustom.toggle()
                                model.onEditingAmount?(editingCustom)
                                customFocused = editingCustom
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Custom")
                                    Image(systemName: editingCustom ? "chevron.up" : "plus").font(.system(size: 9, weight: .semibold))
                                }.foregroundStyle(editingCustom ? Color.cyan : .white.opacity(0.55))
                                    .padding(.vertical, 4)
                            }.buttonStyle(.plain).accessibilityLabel("Custom water amount")
                        }.font(.system(size: 10, weight: .medium))
                        if editingCustom {
                            HStack(spacing: 8) {
                                TextField("Amount", text: $custom)
                                    .textFieldStyle(.plain).focused($customFocused)
                                    .frame(width: 70).onSubmit(logAmount)
                                    .accessibilityLabel("Custom amount in millilitres")
                                Text("ml").foregroundStyle(.white.opacity(0.55))
                                Spacer()
                                Text("1–2,000 ml · Return to log")
                                    .font(.system(size: 10)).foregroundStyle(.white.opacity(0.4))
                            }.font(.system(size: 12)).padding(10)
                                .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 9))
                        }
                    }
                }
    }
}

private struct SipDissolve: ViewModifier {
    var blur: CGFloat
    var opacity: Double
    var scale: CGFloat
    func body(content: Content) -> some View {
        content.blur(radius: blur).opacity(opacity).scaleEffect(scale)
    }
}

private struct SipConfirmation: View {
    let amount: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var settled = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(.cyan.opacity(0.12)).frame(width: 54, height: 54)
                Circle().stroke(.cyan.opacity(settled ? 0 : 0.4), lineWidth: 1)
                    .frame(width: 52, height: 52)
                    .scaleEffect(reduceMotion ? 1 : settled ? 1.5 : 0.85)
                Circle().trim(from: 0, to: settled ? 1 : 0)
                    .stroke(.cyan.opacity(0.55), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    .frame(width: 48, height: 48).rotationEffect(.degrees(-90))
                Image(systemName: "checkmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.cyan)
                    .scaleEffect(reduceMotion ? 1 : settled ? 1 : 0.7)
                    .opacity(settled ? 1 : 0)
            }.frame(width: 60, height: 60)
            VStack(alignment: .leading, spacing: 5) {
                Text("A little sip. A good habit.")
                    .font(.system(size: 17, weight: .semibold))
                Text("\(amount) ml · Feeling refreshed.")
                    .font(.system(size: 12)).foregroundStyle(.white.opacity(0.55))
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 13)
        .accessibilityElement(children: .combine)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.15) : .easeOut(duration: 0.85).delay(0.12)) {
                settled = true
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = Hydration()
    var window: NSWindow!
    var panel: ReminderPanel?
    var statusItem: NSStatusItem!
    var reminderTimer: Timer?
    var dismissTimer: Timer?
    var reminderHovered = false
    var editingAmount = false
    var closeWork: DispatchWorkItem?
    var locked = false
    var activityTimer: Timer?
    var lastActivityCheck = Date()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        model.onScheduleChange = { [weak self] in self?.schedule() }
        model.onShow = { [weak self] in self?.showReminder() }
        model.onDismiss = { [weak self] in self?.dismissReminder() }
        model.onEditingAmount = { [weak self] editing in
            guard let self else { return }
            self.editingAmount = editing
            self.dismissTimer?.invalidate()
            if editing {
                self.reminderTimer?.invalidate()
                self.model.nextReminder = nil
                self.panel?.makeKey()
            } else {
                self.panel?.resignKey()
                self.schedule()
                self.resetDismissTimer()
            }
        }
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 700, height: 690), styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Water, pls"
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: Dashboard(model: model))
        window.center()
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "Water, pls")
        let menu = NSMenu()
        menu.addItem(withTitle: "Open Water, pls", action: #selector(openDashboard), keyEquivalent: "")
        menu.addItem(withTitle: "Show reminder now", action: #selector(showReminder), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Water, pls", action: #selector(quit), keyEquivalent: "q")
        for item in menu.items { item.target = self }
        statusItem.menu = menu
        let center = NSWorkspace.shared.notificationCenter
        center.addObserver(self, selector: #selector(suspend), name: NSWorkspace.willSleepNotification, object: nil)
        center.addObserver(self, selector: #selector(resume), name: NSWorkspace.didWakeNotification, object: nil)
        center.addObserver(self, selector: #selector(suspend), name: NSWorkspace.sessionDidResignActiveNotification, object: nil)
        center.addObserver(self, selector: #selector(resume), name: NSWorkspace.sessionDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(screenChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(suspend), name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(resume), name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
        openDashboard()
        schedule()
        activityTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in self?.checkActivity() }
    }
    @objc func openDashboard() { NSApp.activate(ignoringOtherApps: true); window.makeKeyAndOrderFront(nil) }
    @objc func quit() { NSApp.terminate(nil) }
    func schedule() {
        reminderTimer?.invalidate()
        model.nextReminder = nil
        guard model.preferences.enabled, !locked, !model.isAway, model.remaining > 0 else { return }
        let interval = model.suggestedInterval
        model.nextReminder = Date().addingTimeInterval(interval)
        let timer = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            NSLog("WaterPls: scheduled reminder fired")
            self?.checkActivity()
            if self?.model.isAway == false { self?.showReminder() }
            self?.schedule()
        }
        timer.tolerance = min(1, interval * 0.02)
        RunLoop.main.add(timer, forMode: .common)
        reminderTimer = timer
    }
    func checkActivity() {
        let now = Date()
        let elapsed = min(15, max(0, now.timeIntervalSince(lastActivityCheck)))
        lastActivityCheck = now
        model.refreshDay()
        let idle = CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: CGEventType(rawValue: UInt32.max)!)
        let away = locked || idle >= 120
        if !away { model.trackActivity(seconds: elapsed) }
        if model.isAway != away {
            model.isAway = away
            if away { dismissReminder() }
            schedule()
        }
    }
    @objc func showReminder() {
        guard !locked else { return }
        closeWork?.cancel()
        dismissTimer?.invalidate()
        if let old = panel { old.orderOut(nil) }
        reminderHovered = false
        editingAmount = false
        guard let screen = NSScreen.screens.first(where: { $0.safeAreaInsets.top > 0 }) ?? NSScreen.main else { return }
        let inset = max(screen.safeAreaInsets.top, 12)
        var notchWidth: CGFloat = 180
        if let left = screen.auxiliaryTopLeftArea, let right = screen.auxiliaryTopRightArea {
            notchWidth = max(100, right.minX - left.maxX)
        }
        let frame = NSRect(x: screen.frame.midX - 230, y: screen.frame.maxY - 320, width: 460, height: 320)
        let next = ReminderPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        next.onMouseInteraction = { [weak self] in self?.resetDismissTimer() }
        next.becomesKeyOnlyIfNeeded = true
        next.isOpaque = false
        next.backgroundColor = .clear
        next.hasShadow = false
        next.hidesOnDeactivate = false
        next.isReleasedWhenClosed = false
        next.isMovable = false
        next.level = .statusBar
        next.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        if #available(macOS 15.0, *) { next.collectionBehavior.insert(.canJoinAllApplications) }
        model.expanded = false
        model.confirmation = false
        model.chooseReminderMessage()
        next.contentView = NSHostingView(rootView: NotchView(model: model, notchWidth: notchWidth, topInset: inset) { [weak self, weak next] hovered in
            guard let self, self.panel === next else { return }
            self.reminderHovered = hovered
            self.resetDismissTimer()
        })
        panel = next
        let activeBefore = NSWorkspace.shared.frontmostApplication?.processIdentifier
        next.orderFrontRegardless()
        NSLog("WaterPls: panel visible=%@; foreground preserved=%@; notch=%@", String(next.isVisible), String(activeBefore == NSWorkspace.shared.frontmostApplication?.processIdentifier), String(screen.safeAreaInsets.top > 0))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self, weak next] in
            guard let self, self.panel === next, next?.isVisible == true else { return }
            self.model.expanded = true
            self.resetDismissTimer()
        }
    }
    func resetDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        guard model.expanded, !reminderHovered, !editingAmount else { return }
        dismissTimer = Timer.scheduledTimer(withTimeInterval: model.confirmation ? 3 : 10, repeats: false) { [weak self] _ in
            self?.dismissReminder()
        }
    }
    func dismissReminder() {
        dismissTimer?.invalidate()
        panel?.resignKey()
        if model.nextReminder == nil && !locked { schedule() }
        model.expanded = false
        closeWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.panel?.orderOut(nil) }
        closeWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55, execute: work)
    }
    @objc func suspend() {
        locked = true
        model.isAway = true
        reminderTimer?.invalidate()
        model.nextReminder = nil
        dismissReminder()
        panel?.orderOut(nil)
    }
    @objc func resume() { locked = false; lastActivityCheck = Date(); checkActivity(); schedule() }
    @objc func screenChanged() { dismissReminder(); panel?.orderOut(nil) }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
