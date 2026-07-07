import XCTest
@testable import Jetlagly

@MainActor
final class JetlaglyTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(Entry(tripName: "Test", timezoneShift: "Test2", sleepHours: 1, energyLevel: 2))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(Entry(tripName: "X", timezoneShift: "Y", sleepHours: 1, energyLevel: 1))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() {
        let entry = Entry(tripName: "Del", timezoneShift: "Me", sleepHours: 1, energyLevel: 1)
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        var entry = Entry(tripName: "Old", timezoneShift: "Old2", sleepHours: 1, energyLevel: 1)
        store.add(entry)
        entry.tripName = "New"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.tripName, "New")
    }

    func testDeleteAtOffsets() {
        store.add(Entry(tripName: "A", timezoneShift: "B", sleepHours: 1, energyLevel: 1))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
