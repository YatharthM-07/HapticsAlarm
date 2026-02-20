import Foundation
import UserNotifications

@MainActor
final class AlarmListViewModel: ObservableObject {

    @Published var alarms: [Alarm] = []

    private let storageKey = "saved_alarms"

    init() {
        loadAlarms()
    }

   
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)

        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }

        saveAlarms()
    }

  
    func setAlarm(_ alarm: Alarm, enabled: Bool) {

        guard let index = alarms.firstIndex(of: alarm) else { return }

        alarms[index].isEnabled = enabled

        if enabled {
            scheduleAlarm(alarms[index])
        } else {
            removeScheduledAlarm(alarms[index])
        }

        saveAlarms()
    }

    func isAlarmEnabled(_ alarm: Alarm) -> Bool {
        alarms.first(where: { $0.id == alarm.id })?.isEnabled ?? false
    }

  

    func deleteAlarm(at offsets: IndexSet) {
        for index in offsets {
            removeScheduledAlarm(alarms[index])
        }

        alarms.remove(atOffsets: offsets)
        saveAlarms()
    }

    

    private func scheduleAlarm(_ alarm: Alarm) {

        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
        content.body = "Wake up"
        content.sound = UNNotificationSound(
            named: UNNotificationSoundName("\(alarm.soundID)")
        )
        content.categoryIdentifier = "ALARM_CATEGORY"
        let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: !alarm.repeatDays.isEmpty
        )

        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    

    private func removeScheduledAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }

    

    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
        }
    }
}
