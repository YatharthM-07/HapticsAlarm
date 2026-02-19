//
//  AlarmListViewModel.swift
//  HapticsAlarm
//

import Foundation
import UserNotifications

// Manages alarms, scheduling and persistence
final class AlarmListViewModel: ObservableObject {
    
    @Published var alarms: [Alarm] = []
    
    private let storageKey = "saved_alarms"
    
    // Load saved alarms on startup
    init() {
        loadAlarms()
    }
    
    // Add new alarm
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
        
        if alarm.isEnabled {
            scheduleAlarm(alarm)
        }
        
        saveAlarms()
    }
    
    // Enable / disable alarm
    func toggleAlarm(_ alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            
            alarms[index].isEnabled.toggle()
            
            if alarms[index].isEnabled {
                scheduleAlarm(alarms[index])
            } else {
                removeScheduledAlarm(alarms[index])
            }
            
            saveAlarms()
        }
    }
    
    // Delete alarm
    func deleteAlarm(at offsets: IndexSet) {
        for index in offsets {
            removeScheduledAlarm(alarms[index])
        }
        
        alarms.remove(atOffsets: offsets)
        saveAlarms()
    }
    
    // Schedule system notification
    func scheduleAlarm(_ alarm: Alarm) {
        
        let content = UNMutableNotificationContent()
        content.title = alarm.label.isEmpty ? "Alarm" : alarm.label
        content.body = "Wake up"
        content.sound = .default
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
    
    // Cancel scheduled notification
    func removeScheduledAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [alarm.id.uuidString])
    }
    
    // Save alarms locally
    private func saveAlarms() {
        if let encoded = try? JSONEncoder().encode(alarms) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    // Load alarms from storage
    private func loadAlarms() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Alarm].self, from: data) {
            alarms = decoded
        }
    }
}
