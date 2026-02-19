import SwiftUI

struct AlarmListView: View {
    
    @EnvironmentObject var viewModel: AlarmListViewModel
    @State private var showAddAlarm = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.alarms) { alarm in
                    HStack {
                        
                        VStack(alignment: .leading) {
                            Text(alarm.time, style: .time)
                                .font(.system(size: 36, weight: .light))
                            
                            Text(alarm.label)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { alarm.isEnabled },
                            set: { _ in viewModel.toggleAlarm(alarm) }
                        ))
                        .labelsHidden()
                    }
                    .padding(.vertical, 8)
                }
                .onDelete { indexSet in
                    viewModel.deleteAlarm(at: indexSet)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Alarm")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddAlarm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddAlarm) {
                AddAlarmView { newAlarm in
                    viewModel.addAlarm(newAlarm)
                }
            }
        }
    }
}
