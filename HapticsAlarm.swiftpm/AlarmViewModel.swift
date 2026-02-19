import Foundation
import Combine

@MainActor
final class AlarmViewModel: ObservableObject {
    
    @Published var intensity: Float = 0.2
    @Published var isRinging = false
    
    private let hapticEngine = HapticEngine()
    private let audioManager = AudioManager.shared
    
    private var alarmStartTime: Date?
    private var escalationTimer: Timer?
    private var secondsElapsed: Int = 0
    
    // Start alarm with selected sound
    func startAlarm(soundID: String) {
        
        isRinging = true
        alarmStartTime = Date()
        secondsElapsed = 0
        
        intensity = UserDefaults.standard.float(forKey: "adaptiveBaseIntensity")
        if intensity == 0 { intensity = 0.15 }
        
        escalate(soundID: soundID)
    }
    
    // Escalates haptics and later introduces sound
    private func escalate(soundID: String) {
        
        escalationTimer?.invalidate()
        
        escalationTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            
            guard self.isRinging else { return }
            
            self.secondsElapsed += 1
            
            // Play haptic wave
            self.hapticEngine.playBreathingWave(intensity: self.intensity)
            
            // Nonlinear intensity growth
            if self.intensity < 1.0 {
                self.intensity += (1.0 - self.intensity) * 0.25
            }
            
            // After ~20 seconds introduce sound
            if self.secondsElapsed == 14 {
                self.audioManager.play(soundName: soundID)
            }
        }
    }
    
    // Adapt baseline intensity based on response speed
    private func adaptBasedOn(responseTime: TimeInterval) {
        
        var base = UserDefaults.standard.float(forKey: "adaptiveBaseIntensity")
        if base == 0 { base = 0.15 }
        
        if responseTime > 15 {
            base += 0.1
        } else if responseTime < 5 {
            base -= 0.05
        }
        
        base = min(max(base, 0.1), 0.8)
        
        UserDefaults.standard.set(base, forKey: "adaptiveBaseIntensity")
    }
    
    // Stop everything
    func stopAlarm() {
        
        isRinging = false
        escalationTimer?.invalidate()
        
        hapticEngine.stop()
        audioManager.stop()
        
        if let start = alarmStartTime {
            let responseTime = Date().timeIntervalSince(start)
            adaptBasedOn(responseTime: responseTime)
        }
    }
}
