import SwiftUI

struct SoundSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: String
    
    // Available alarm sounds (must exist in bundle as .mp3)
    private let sounds = ["radial", "beacon", "chime", "signal"]
    
    var body: some View {
        List {
            ForEach(sounds, id: \.self) { sound in
                
                Button {
                    selected = sound
                    AudioManager.shared.play(soundName: sound)
                    AudioManager.shared.fadeIn(duration: 0.3)
                } label: {
                    HStack {
                        Text(sound)
                        Spacer()
                        if selected == sound {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Sound")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    finalizeSelection()
                }
            }
        }
        .onDisappear {
            AudioManager.shared.stop()
        }
    }
    
    private func finalizeSelection() {
        if selected.isEmpty {
            selected = sounds.first ?? "radial"
        }
        AudioManager.shared.stop()
        dismiss()
    }
}
