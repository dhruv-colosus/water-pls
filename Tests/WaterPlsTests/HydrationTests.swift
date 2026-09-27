import XCTest
@testable import WaterPls

final class HydrationTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suite: String!
    override func setUp() {
        suite = "water-pls.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)!
    }
    override func tearDown() { defaults.removePersistentDomain(forName: suite) }

    func testExistingEntriesSurviveAndWeekIncludesEmptyDays() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let entries = [Drink(date: yesterday, millilitres: 500), Drink(date: Date(), millilitres: 250)]
        defaults.set(try JSONEncoder().encode(entries), forKey: "water-pls.drinks")
        let model = Hydration(defaults: defaults)
        XCTAssertEqual(model.today, 250)
        XCTAssertEqual(model.week.count, 7)
        XCTAssertEqual(model.week[5].amount, 500)
        XCTAssertNil(model.week[5].goal)
        XCTAssertEqual(model.week[0].amount, 0)
        model.log(100)
        XCTAssertEqual(Hydration(defaults: defaults).today, 350)
    }
    func testInvalidAmountsUndoAndGoalCompletion() {
        let model = Hydration(defaults: defaults)
        model.log(0); model.log(-100); model.log(2001)
        XCTAssertEqual(model.today, 0)
        model.log(2000); model.log(250)
        XCTAssertEqual(model.remaining, 0)
        model.undoLastDrink()
        XCTAssertEqual(model.today, 2000)
        XCTAssertEqual(Hydration(defaults: defaults).today, 2000)
    }
    func testEditingAndResettingTodayPreservesEarlierDrinks() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        defaults.set(try JSONEncoder().encode([Drink(date: yesterday, millilitres: 500)]), forKey: "water-pls.drinks")
        let model = Hydration(defaults: defaults)
        model.log(250)
        model.log(100)
        model.setTodayTotal(750)
        XCTAssertEqual(model.today, 750)
        XCTAssertEqual(model.total(on: yesterday), 500)
        XCTAssertEqual(model.drinks.count, 2)
        XCTAssertEqual(model.remaining, 1250)
        XCTAssertEqual(Hydration(defaults: defaults).today, 750)

        model.setTodayTotal(0)
        XCTAssertEqual(model.today, 0)
        XCTAssertEqual(model.total(on: yesterday), 500)
        XCTAssertEqual(Hydration(defaults: defaults).today, 0)
        model.setTodayTotal(-1)
        XCTAssertEqual(model.today, 0)
    }
    func testPacingAndPreferencesPersist() {
        let model = Hydration(defaults: defaults)
        XCTAssertEqual(model.suggestedInterval, 3600)
        model.trackActivity(seconds: 4 * 3600)
        XCTAssertEqual(model.suggestedInterval, 1800)
        model.log(1000)
        XCTAssertEqual(model.suggestedInterval, 3600)
        model.trackActivity(seconds: 10 * 3600)
        XCTAssertEqual(model.suggestedInterval, 900)
        model.preferences.automatic = false
        model.preferences.interval = 5400
        model.preferences.enabled = false
        model.preferences.goal = 3000
        let restored = Hydration(defaults: defaults)
        XCTAssertEqual(restored.suggestedInterval, 5400)
        XCTAssertFalse(restored.preferences.enabled)
        XCTAssertEqual(restored.preferences.goal, 3000)
        XCTAssertEqual(restored.activeSeconds, 14 * 3600)
    }
    func testHistoricalGoalIsPreserved() throws {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: yesterday)
        let key = "\(parts.year!)-\(parts.month!)-\(parts.day!)"
        defaults.set(try JSONEncoder().encode([key: DayRecord(goal: 1750)]), forKey: "water-pls.days")
        let model = Hydration(defaults: defaults)
        model.preferences.goal = 3000
        XCTAssertEqual(model.week[5].goal, 1750)
        XCTAssertEqual(model.week[6].goal, 3000)
    }
}
