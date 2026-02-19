import SwiftUI

struct AlarmListView: View {

    @EnvironmentObject var viewModel: AlarmListViewModel
    @State private var showAddAlarm = false

    var body: some View {

        NavigationStack {

            List {

                ForEach(viewModel.alarms) { alarm in

                    HStack {

                        VStack(alignment: .leading, spacing: 4) {

                            Text(alarm.time, style: .time)
                                .font(.system(size: 36, weight: .light))
                                .foregroundColor(
                                    alarm.isEnabled ? .primary : .gray
                                )

                            Text(alarm.label)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Toggle(
                            "",
                            isOn: Binding(
                                get: {
                                    viewModel.isAlarmEnabled(alarm)
                                },
                                set: { newValue in
                                    viewModel.setAlarm(alarm, enabled: newValue)
                                }
                            )
                        )
                        .labelsHidden()
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: viewModel.deleteAlarm)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Alarm")
            .toolbar {

                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }

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
                .environmentObject(viewModel)
            }
        }
    }
}
