import Foundation
import Combine

struct Drink: Codable {
    let date: Date
    let millilitres: Int
}

struct DayRecord: Codable {
    var goal: Int
    var activeSeconds: Double = 0
}

struct HydrationDay: Identifiable {
    let date: Date
    let amount: Int
    let goal: Int?
    var id: Date { date }
}

struct Preferences: Codable {
    var goal = 2000
    var serving = 250
    var automatic = true
    var activeHours = 8
    var interval: TimeInterval = 3600
    var enabled = true
}

final class Hydration: ObservableObject {
    private static let reminderMessages = [
        "Sip, sip, hooray!",
        "Your water misses you.",
        "A tiny toast to you.",
        "Stay splashy, friend.",
        "Plot twist: water break.",
        "Sip happens. Make it now.",
        "Just add water. That's you.",
        "A little pour of kindness.",
        "Pause. Sip. Carry on.",
        "Your glass is calling.",
        "Water you waiting for?",
        "Keep calm and sip on.",
        "A sip-sized intermission.",
        "Cheers, you lovely human.",
        "Give your day a splash.",
        "Refill your inner goldfish.",
        "One small sip for you.",
        "Psst. It's water o'clock."
    ]
    @Published private(set) var reminderMessage = ""

    func chooseReminderMessage() {
        reminderMessage = Self.reminderMessages
            .filter { $0 != reminderMessage }
            .randomElement() ?? Self.reminderMessages[0]
    }

    @Published var drinks: [Drink] = []
    @Published var preferences = Preferences() {
        didSet {
            save(preferences, key: "preferences")
            rememberToday()
            onScheduleChange?()
        }
    }
    @Published private(set) var days: [String: DayRecord] = [:]
    @Published var nextReminder: Date?
    @Published var expanded = false
    @Published var confirmation = false
    @Published var isAway = false
    @Published var currentDay = Calendar.current.startOfDay(for: Date())
    var onScheduleChange: (() -> Void)?
    var onShow: (() -> Void)?
    var onDismiss: (() -> Void)?
    var onEditingAmount: ((Bool) -> Void)?
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "water-pls.drinks"),
           let saved = try? JSONDecoder().decode([Drink].self, from: data) { drinks = saved }
        if let data = defaults.data(forKey: "water-pls.days"),
           let saved = try? JSONDecoder().decode([String: DayRecord].self, from: data) { days = saved }
        if let data = defaults.data(forKey: "water-pls.preferences"),
           let saved = try? JSONDecoder().decode(Preferences.self, from: data) { preferences = saved }
        rememberToday()
    }
    private func dayKey(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year!)-\(parts.month!)-\(parts.day!)"
    }
    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: "water-pls.\(key)") }
    }
    private func rememberToday() {
        let key = dayKey(Date())
        var record = days[key] ?? DayRecord(goal: preferences.goal)
        record.goal = preferences.goal
        days[key] = record
        save(days, key: "days")
    }
    func refreshDay() {
        let day = Calendar.current.startOfDay(for: Date())
        if day != currentDay { currentDay = day; rememberToday(); onScheduleChange?() }
    }
    func trackActivity(seconds: Double) {
        refreshDay()
        let key = dayKey(Date())
        var record = days[key] ?? DayRecord(goal: preferences.goal)
        record.activeSeconds += seconds
        days[key] = record
        save(days, key: "days")
    }
    var today: Int { total(on: Date()) }
    var remaining: Int { max(0, preferences.goal - today) }
    var activeSeconds: Double { days[dayKey(Date())]?.activeSeconds ?? 0 }
    var suggestedInterval: TimeInterval {
        guard preferences.automatic else { return preferences.interval }
        let servings = max(1, Int(ceil(Double(remaining) / Double(preferences.serving))))
        let timeLeft = max(0, Double(preferences.activeHours) * 3600 - activeSeconds)
        return min(7200, max(900, timeLeft / Double(servings)))
    }
    func total(on date: Date) -> Int {
        drinks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.millilitres }
    }
    var week: [HydrationDay] {
        (0..<7).reversed().map { offset in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: currentDay)!
            return HydrationDay(date: date, amount: total(on: date), goal: days[dayKey(date)]?.goal)
        }
    }
    func log(_ amount: Int) {
        guard (1...2000).contains(amount) else { return }
        refreshDay()
        drinks.append(Drink(date: Date(), millilitres: amount))
        save(drinks, key: "drinks")
        onScheduleChange?()
    }
    func undoLastDrink() {
        guard let last = drinks.last, Calendar.current.isDateInToday(last.date) else { return }
        drinks.removeLast()
        save(drinks, key: "drinks")
        onScheduleChange?()
    }
}
