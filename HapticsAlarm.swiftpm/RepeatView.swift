import SwiftUI

struct RepeatView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Int>   // 1 = Sunday ... 7 = Saturday
    
    private let calendar = Calendar.current
    private var weekdays: [(name: String, value: Int)] {
        
        let symbols = calendar.weekdaySymbols ?? []
        
        return symbols.enumerated().map { index, name in
            (name, index + 1)
        }
    }
    
    var body: some View {
        List {
            ForEach(weekdays, id: \.value) { day in
                
                Button {
                    toggle(day.value)
                } label: {
                    HStack {
                        Text(day.name)
                        Spacer()
                        if selectedDays.contains(day.value) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Repeat")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func toggle(_ value: Int) {
        if selectedDays.contains(value) {
            selectedDays.remove(value)
        } else {
            selectedDays.insert(value)
        }
    }
}
