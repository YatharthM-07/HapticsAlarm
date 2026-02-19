import Foundation
import CoreHaptics

final class HapticEngine {
    
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    
    init() {
        prepareEngine()
    }
    
    private func prepareEngine() {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine error:", error)
        }
    }
    
    func playBreathingWave(intensity: Float) {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        try? engine?.start()
        
        let intensityParam = CHHapticEventParameter(
            parameterID: .hapticIntensity,
            value: intensity
        )
        
        let sharpnessParam = CHHapticEventParameter(
            parameterID: .hapticSharpness,
            value: 0.4
        )
        
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParam, sharpnessParam],
            relativeTime: 0,
            duration: 1.0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Haptic play error:", error)
        }
    }
    
    func stop() {
        try? player?.stop(atTime: 0)
        try? engine?.stop()
    }
}
