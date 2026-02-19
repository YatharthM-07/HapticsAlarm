//
//  LabelEditView.swift
//  HapticsAlarm
//

import SwiftUI

struct LabelEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    
    var body: some View {
        Form {
            TextField("Label", text: $text)
                .autocorrectionDisabled()
        }
        .navigationTitle("Label")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    
                    // Prevent empty label
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        text = "Alarm"
                    }
                    
                    dismiss()
                }
            }
        }
    }
}
