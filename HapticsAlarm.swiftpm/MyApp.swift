import SwiftUI

@main
struct MyApp: App {
    
    init() {
        NotificationManager.shared.requestPermission()
        NotificationManager.shared.configureCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
