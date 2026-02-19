//
//  RepeatView.swift
//  HapticsAlarm
//

import SwiftUI

struct RepeatView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDays: Set<Int>   // 1 = Sunday ... 7 = Saturday
    
    private let days: [(name: String, value: Int)] = [
        ("Sunday", 1),
        ("Monday", 2),
        ("Tuesday", 3),
        ("Wednesday", 4),
        ("Thursday", 5),
        ("Friday", 6),
        ("Saturday", 7)
    ]
    
    var body: some View {
        List {
            ForEach(days, id: \.value) { day in
                Button {
                    
                    if selectedDays.contains(day.value) {
                        selectedDays.remove(day.value)
                    } else {
                        selectedDays.insert(day.value)
                    }
                    
                } label: {
                    HStack {
                        Text(day.name)
                        Spacer()
                        if selectedDays.contains(day.value) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("Repeat")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
