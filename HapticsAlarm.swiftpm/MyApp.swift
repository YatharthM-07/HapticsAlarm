import SwiftUI
import UserNotifications

@main
struct MyApp: App {
    
    init() {
        setupNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
    
    private func setupNotifications() {
        
        let center = UNUserNotificationCenter.current()
        
        // Set delegate early
        center.delegate = NotificationManager.shared
        
        // Request permission
        NotificationManager.shared.requestPermission()
        
        // Configure alarm categories
        NotificationManager.shared.configureCategories()
    }
}
