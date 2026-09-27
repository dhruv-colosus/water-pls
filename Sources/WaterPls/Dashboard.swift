import SwiftUI

struct Dashboard: View {
    @ObservedObject var model: Hydration
    @State private var settings = false
    @State private var customEntry = false
    @State private var custom = ""
    @State private var selectedDay: Date?
    @State private var justLogged = false
    private let blue = Color.blue
    private var selected: HydrationDay? { model.week.first { $0.date == selectedDay } }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 10) {
                Image(systemName: "drop.fill").foregroundStyle(blue).font(.title2)
                Text("water, pls").font(.system(size: 19, weight: .semibold, design: .rounded))
                Spacer()
                Text(Date(), format: .dateTime.weekday(.wide).month(.abbreviated).day())
                    .foregroundStyle(.secondary).font(.callout)
                Button { settings = true } label: { Image(systemName: "slider.horizontal.3") }
                    .help("Goal & reminders").accessibilityLabel("Goal and reminder settings")
            }
            VStack(alignment: .leading, spacing: 22) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today’s water").font(.system(size: 18, weight: .semibold))
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(model.today.formatted()).font(.system(size: 48, weight: .semibold, design: .rounded)).monospacedDigit()
                            Text("/ \(model.preferences.goal.formatted()) ml").foregroundStyle(.secondary)
                        }
                        Text(model.remaining == 0 ? "Daily goal reached. Nicely done." : "\(model.remaining.formatted()) ml left · a little at a time.")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    Spacer()
                    ZStack {
                        Circle().stroke(blue.opacity(0.12), lineWidth: 7)
                        Circle().trim(from: 0, to: min(1, Double(model.today) / Double(model.preferences.goal)))
                            .stroke(blue.gradient, style: StrokeStyle(lineWidth: 7, lineCap: .round)).rotationEffect(.degrees(-90))
                        if model.remaining == 0 {
                            Image(systemName: "checkmark").font(.system(size: 25, weight: .medium)).foregroundStyle(blue)
                        } else {
                            WaterGlass(outlineColor: blue).frame(width: 36, height: 36)
                        }
                    }.frame(width: 72, height: 72).padding(4)
                        .accessibilityLabel("\(Int(Double(model.today) / Double(model.preferences.goal) * 100)) percent of daily goal")
                }
                Divider()
                HStack(spacing: 8) {
                    Text("Log a drink").font(.callout.weight(.medium))
                    Spacer()
                    ForEach([100, 250, 500], id: \.self) { amount in
                        Button("+ \(amount) ml") { model.log(amount); justLogged = true }
                            .controlSize(.large)
                    }
                    Button { customEntry = true } label: { Image(systemName: "plus") }
                        .controlSize(.large).help("Custom amount").accessibilityLabel("Log a custom amount")
                        .popover(isPresented: $customEntry) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Log water").font(.headline)
                                TextField("Amount in ml", text: $custom).textFieldStyle(.roundedBorder).onSubmit(logCustom)
                                Text("1–2,000 ml").font(.caption).foregroundStyle(.secondary)
                                Button("Add water", action: logCustom).buttonStyle(.borderedProminent)
                                    .disabled(validAmount == nil)
                            }.padding(20).frame(width: 230)
                        }
                }
            }.padding(24).background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.primary.opacity(0.06)))

            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your last 7 days").font(.system(size: 18, weight: .semibold))
                        Text(selected.map { "\($0.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())) · \($0.amount.formatted()) ml" } ?? "Small sips. A clearer picture.")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(blue).frame(width: 7, height: 7)
                        Text("Drank")
                        Circle().fill(blue.opacity(0.15)).frame(width: 7, height: 7).padding(.leading, 8)
                        Text("To goal")
                    }.font(.caption).foregroundStyle(.secondary)
                }
                historyChart
                HStack {
                    if let day = selected {
                        Text(day.goal.map { "Goal \($0.formatted()) ml · \(max(0, $0 - day.amount).formatted()) ml remaining" } ?? "No goal recorded for this day")
                    } else {
                        Text("\(model.week.reduce(0) { $0 + $1.amount }.formatted()) ml logged this week")
                    }
                    Spacer()
                    Text("Select a day for details")
                }.font(.caption).foregroundStyle(.secondary)
            }.padding(24).background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.primary.opacity(0.06)))
            HStack(spacing: 8) {
                Image(systemName: model.preferences.enabled ? "bell" : "bell.slash").foregroundStyle(.secondary)
                reminderStatus
                Spacer()
                if justLogged {
                    Button("Undo last drink") { model.undoLastDrink(); justLogged = false }.buttonStyle(.link)
                } else {
                    Text("Stored on this Mac").foregroundStyle(.tertiary)
                }
            }.font(.caption).padding(.horizontal, 4)
        }
        .padding(28).frame(width: 700).background(Color(nsColor: .windowBackgroundColor)).tint(blue)
        .sheet(isPresented: $settings) { HydrationSettings(model: model) }
    }
    private var validAmount: Int? { Int(custom).flatMap { (1...2000).contains($0) ? $0 : nil } }
    private func logCustom() {
        guard let amount = validAmount else { return }
        model.log(amount); custom = ""; customEntry = false; justLogged = true
    }
    @ViewBuilder private var reminderStatus: some View {
        if !model.preferences.enabled { Text("Reminders paused") }
        else if model.remaining == 0 { Text("Goal reached · reminders done for today") }
        else if model.isAway { Text("Reminders resume when you’re back") }
        else if let next = model.nextReminder {
            Text("Next sip at \(next.formatted(date: .omitted, time: .shortened))")
        } else { Text("Reminders ready") }
    }
    private var historyChart: some View {
        let maximum = Double(max(model.preferences.goal, model.week.map { max($0.amount, $0.goal ?? 0) }.max() ?? 2000))
        return HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .trailing) {
                Text("\(Int(maximum).formatted())")
                Spacer()
                Text("ml")
                Spacer()
                Text("0")
            }.font(.system(size: 10)).foregroundStyle(.tertiary).frame(width: 38, height: 174)
            HStack(alignment: .bottom, spacing: 22) {
                ForEach(model.week) { day in
                    let today = Calendar.current.isDateInToday(day.date)
                    Button { selectedDay = selectedDay == day.date ? nil : day.date } label: {
                        VStack(spacing: 10) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 9).fill(.primary.opacity(0.025)).frame(height: 174)
                                RoundedRectangle(cornerRadius: 9).fill(blue.opacity(0.12))
                                    .frame(height: max(0, Double(day.goal ?? 0) / maximum * 174))
                                RoundedRectangle(cornerRadius: 9).fill(blue.gradient)
                                    .frame(height: day.amount == 0 ? 0 : max(4, Double(day.amount) / maximum * 174))
                            }.frame(height: 174)
                            Text(today ? "Today" : day.date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.system(size: 11, weight: today || selectedDay == day.date ? .semibold : .regular))
                                .foregroundStyle(today || selectedDay == day.date ? Color.primary : .secondary)
                        }.padding(.horizontal, 3)
                    }.buttonStyle(.plain)
                        .focusEffectDisabled()
                        .help("\(day.date.formatted(date: .abbreviated, time: .omitted)): \(day.amount) ml")
                        .accessibilityLabel("\(day.date.formatted(date: .complete, time: .omitted)), \(day.amount) millilitres. \(day.goal.map { "Goal \($0) millilitres" } ?? "No goal recorded")")
                        .accessibilityAddTraits(selectedDay == day.date ? .isSelected : [])
                }
            }
        }
    }
}

struct HydrationSettings: View {
    @ObservedObject var model: Hydration
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Goal & reminders").font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }.keyboardShortcut(.defaultAction)
            }.padding(24)
            Form {
                Section("Your daily rhythm") {
                    Stepper("Daily goal: \(model.preferences.goal.formatted()) ml", value: $model.preferences.goal, in: 250...5000, step: 250)
                    Picker("Usual glass", selection: $model.preferences.serving) {
                        Text("100 ml").tag(100); Text("250 ml").tag(250); Text("500 ml").tag(500)
                    }
                    Text("Choose a goal that works for you. It’s a personal target, not a recommendation.").font(.caption).foregroundStyle(.secondary)
                }
                Section("Reminders") {
                    Toggle("Enable reminders", isOn: $model.preferences.enabled)
                    Picker("Pacing", selection: $model.preferences.automatic) {
                        Text("Automatic").tag(true); Text("Fixed interval").tag(false)
                    }.pickerStyle(.segmented)
                    if model.preferences.automatic {
                        Stepper("Expected Mac use: \(model.preferences.activeHours) hours / day", value: $model.preferences.activeHours, in: 1...16)
                        Text("About one \(model.preferences.serving) ml glass every \(Int(model.suggestedInterval / 60)) minutes at your current pace.").font(.callout)
                        Text("Spaces your remaining goal across your remaining Mac-use hours. Adjusts after each drink; limited to every 15–120 minutes. Activity is measured only while this app runs, not from macOS Screen Time.").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Picker("Remind every", selection: $model.preferences.interval) {
                            ForEach([15, 30, 45, 60, 90, 120], id: \.self) { minutes in
                                Text("\(minutes) minutes").tag(TimeInterval(minutes * 60))
                            }
                        }
                    }
                    Text("Pauses after 2 minutes away, during lock or sleep, and once you reach your goal. Returning starts a fresh interval.").font(.caption).foregroundStyle(.secondary)
                    Button("Preview reminder") { model.onShow?() }
                }
            }.formStyle(.grouped)
        }.frame(width: 490, height: 575)
    }
}
