import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var tripName: String
    var timezoneShift: String
    var sleepHours: Double
    var energyLevel: Double
    var date: Date = Date()
    var notes: String = ""
}
