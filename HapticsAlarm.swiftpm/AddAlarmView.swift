import SwiftUI

struct AddAlarmView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var repeatDays: Set<Int> = []   // Proper repeat storage
    @State private var label = "Alarm"
    @State private var sound = "Radial"
    @State private var snoozeEnabled = true
    
    var onSave: (Alarm) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxHeight: 220)
                .clipped()
                
                Form {
                    Section {
                        
                        NavigationLink {
                            RepeatView(selectedDays: $repeatDays)
                        } label: {
                            HStack {
                                Text("Repeat")
                                Spacer()
                                Text(repeatSummary())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        NavigationLink {
                            LabelEditView(text: $label)
                        } label: {
                            HStack {
                                Text("Label")
                                Spacer()
                                Text(label)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        NavigationLink {
                            SoundSelectionView(selected: $sound)
                        } label: {
                            HStack {
                                Text("Sound")
                                Spacer()
                                Text(sound)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Toggle("Snooze", isOn: $snoozeEnabled)
                    }
                }
                .scrollDisabled(true)
            }
            .navigationTitle("Add Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        
                        let newAlarm = Alarm(
                            time: selectedTime,
                            repeatDays: repeatDays,
                            label: label,
                            soundID: sound,
                            snoozeEnabled: snoozeEnabled,
                            isEnabled: true
                        )
                        
                        onSave(newAlarm)
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Converts selected days to display text
    private func repeatSummary() -> String {
        if repeatDays.isEmpty { return "Never" }
        
        let formatter = DateFormatter()
        guard let symbols = formatter.shortWeekdaySymbols else {
            return "Repeat"
        }
        
        let sortedDays = repeatDays.sorted()
        let names = sortedDays.map { symbols[$0 - 1] }
        
        return names.joined(separator: " ")
    }
}
