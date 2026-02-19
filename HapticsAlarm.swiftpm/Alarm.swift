import Foundation

struct Alarm: Identifiable, Codable {
    
    var id: UUID
    var time: Date
    var repeatDays: Set<Int>   // 1 = Sunday ... 7 = Saturday
    var label: String
    var soundID: String
    var snoozeEnabled: Bool
    var isEnabled: Bool
    
    init(
        id: UUID = UUID(),
        time: Date,
        repeatDays: Set<Int> = [],
        label: String = "Alarm",
        soundID: String = "default",
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
}
