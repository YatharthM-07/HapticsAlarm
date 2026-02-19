//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        AlarmListView()
//    }
//}
import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel = AlarmListViewModel()
    @State private var activeAlarm: Alarm?
    
    var body: some View {
        ZStack {
            
            AlarmListView()
                .environmentObject(viewModel)
            
            // Temporary simulation button
            VStack {
                Spacer()
                
                Button("Simulate Alarm") {
                    activeAlarm = Alarm(
                        time: Date(),
                        repeatDays: [],
                        label: "Morning Alarm",
                        soundID: "Radial",
                        snoozeEnabled: true,
                        isEnabled: true
                    )
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .padding(.bottom, 40)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ALARM_TRIGGERED"))) { notification in
            
            guard let idString = notification.object as? String,
                  let uuid = UUID(uuidString: idString),
                  let alarm = viewModel.alarms.first(where: { $0.id == uuid }) else {
                return
            }
            
            activeAlarm = alarm
        }
        .fullScreenCover(item: $activeAlarm) { alarm in
            AlarmRingingView(alarm: alarm)
        }
    }
}
