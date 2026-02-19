import Foundation

struct Alarm: Identifiable, Codable, Equatable {
    
    let id: UUID
    var time: Date
    var repeatDays: Set<Int>
    var label: String
    var soundID: String
    var snoozeEnabled: Bool
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        time: Date,
        repeatDays: Set<Int> = [],
        label: String = "Alarm",
        soundID: String = "radial",
        snoozeEnabled: Bool = true,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.time = time
        self.repeatDays = repeatDays
        self.label = label
        self.soundID = soundID
        self.snoozeEnabled = snoozeEnabled
        self.isEnabled = isEnabled
    }
    
    // MARK: Time Formatter
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    // MARK: Equatable (Compare by ID only)
    
    static func == (lhs: Alarm, rhs: Alarm) -> Bool {
        lhs.id == rhs.id
    }
}
