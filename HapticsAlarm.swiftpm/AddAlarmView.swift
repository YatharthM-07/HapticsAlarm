import SwiftUI

struct AddAlarmView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTime = Date()
    @State private var repeatDays: Set<Int> = []
    @State private var label = "Alarm"
    @State private var sound = "radial"
    @State private var snoozeEnabled = true
    
    var onSave: (Alarm) -> Void
    
    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                
                // Time Picker
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
                        
                        // Normalize time to hour + minute only
                        let calendar = Calendar.current
                        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
                        let normalizedTime = calendar.date(from: components) ?? selectedTime
                        
                        // Ensure label is not empty
                        let finalLabel = label
                            .trimmingCharacters(in: .whitespaces)
                            .isEmpty ? "Alarm" : label
                        
                        let newAlarm = Alarm(
                            time: normalizedTime,
                            repeatDays: repeatDays,
                            label: finalLabel,
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
    
    // Converts selected repeat days into readable summary
    private func repeatSummary() -> String {
        
        if repeatDays.isEmpty {
            return "Never"
        }
        
        let formatter = DateFormatter()
        guard let symbols = formatter.shortWeekdaySymbols else {
            return "Repeat"
        }
        
        let sortedDays = repeatDays.sorted()
        let names = sortedDays.map { symbols[$0 - 1] }
        
        return names.joined(separator: " ")
    }
}
