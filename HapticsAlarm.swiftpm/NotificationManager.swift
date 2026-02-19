//
//  NotificationManager.swift
//  HapticsAlarm
//

import UserNotifications
import SwiftUI

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    @MainActor static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request notification permission
    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, error in
                if let error = error {
                    print("Notification permission error:", error)
                }
            }
    }
    
    // Register alarm category with stop and snooze
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


    // Handle notification interaction safely (Swift 6 compliant)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        
        // Extract everything BEFORE hopping to MainActor
        let identifier = response.notification.request.identifier
        let actionIdentifier = response.actionIdentifier
        
        await MainActor.run {
            
            switch actionIdentifier {
                
            case "STOP_ACTION":
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_STOP"),
                    object: identifier
                )
                
            case "SNOOZE_ACTION":
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_SNOOZE"),
                    object: identifier
                )
                
            default:
                NotificationCenter.default.post(
                    name: Notification.Name("ALARM_TRIGGERED"),
                    object: identifier
                )
            }
        }
    }
}
