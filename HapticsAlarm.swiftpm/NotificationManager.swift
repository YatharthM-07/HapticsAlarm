//
//  NotificationManager.swift
//

import UserNotifications

@MainActor
final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // MARK: Permission
    
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Notification permission error:", error)
                }
            }
    }
    
    // MARK: Categories
    
    func configureCategories() {
        
        let stopAction = UNNotificationAction(
            identifier: "STOP_ACTION",
            title: "Stop",
            options: [.destructive]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze",
            options: []
        )
        
        let category = UNNotificationCategory(
            identifier: "ALARM_CATEGORY",
            actions: [stopAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current()
            .setNotificationCategories([category])
    }
    
    // MARK: Foreground Presentation
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        
        let identifier = notification.request.identifier
        
        await MainActor.run {
            NotificationCenter.default.post(
                name: Notification.Name("ALARM_TRIGGERED"),
                object: identifier
            )
        }
        
        return [.sound, .banner]
    }
    
    // MARK: Interaction
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        
        let identifier = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        
        await MainActor.run {
            
            switch actionIdentifier {
                
            case "STOP_ACTION":
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_STOP"),
                    object: identifier)
                
            case "SNOOZE_ACTION":
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_SNOOZE"),
                    object: identifier)
                
            default:
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_TRIGGERED"),
                    object: identifier)
            }
        }
    }
}
