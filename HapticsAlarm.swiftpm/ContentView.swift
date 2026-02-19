import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = AlarmListViewModel()
    @State private var activeAlarm: Alarm?

    var body: some View {

        AlarmListView()
            .environmentObject(viewModel)

            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("ALARM_TRIGGERED")
                )
            ) { notification in

                guard
                    let idString = notification.object as? String,
                    let uuid = UUID(uuidString: idString),
                    let alarm = viewModel.alarms.first(where: { $0.id == uuid })
                else { return }

                activeAlarm = alarm
            }

            .fullScreenCover(item: $activeAlarm) { alarm in
                AlarmRingingView(alarm: alarm)
            }
    }
}
