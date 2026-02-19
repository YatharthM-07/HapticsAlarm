//
//  SoundSelectionView.swift
//  HapticsAlarm
//

import SwiftUI

struct SoundSelectionView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var selected: String
    
    // Available alarm sounds (must exist in bundle as .mp3)
    private let sounds = ["Radial", "Beacon", "Chime", "Signal"]
    
    var body: some View {
        List {
            ForEach(sounds, id: \.self) { sound in
                Button {
                    selected = sound
                } label: {
                    HStack {
                        Text(sound)
                        Spacer()
                        if selected == sound {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
        .navigationTitle("Sound")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    if selected.isEmpty {
                        selected = sounds.first ?? "Radial"
                    }
                    dismiss()
                }
            }
        }
    }
}
