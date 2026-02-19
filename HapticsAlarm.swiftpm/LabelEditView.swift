import SwiftUI

struct LabelEditView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    private let maxLength = 40
    
    var body: some View {
        Form {
            TextField("Label", text: $text)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isFocused)
                .onChange(of: text) { newValue in
                    if newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
        }
        .navigationTitle("Label")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    finalizeLabel()
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func finalizeLabel() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        text = trimmed.isEmpty ? "Alarm" : trimmed
        dismiss()
    }
}
