import Foundation
import Combine

@MainActor
final class AlarmViewModel: ObservableObject {

    @Published var intensity: Float = 0.2
    @Published var isRinging = false

    private let hapticEngine = HapticEngine()
    private let audioManager = AudioManager.shared

    private var escalationTask: Task<Void, Never>?
    private var alarmStartTime: Date?
    private var soundStarted = false

    func startAlarm(soundID: String) {

        guard !isRinging else { return }

        isRinging = true
        alarmStartTime = Date()
        soundStarted = false

        intensity = UserDefaults.standard.float(forKey: "adaptiveBaseIntensity")
        if intensity == 0 { intensity = 0.15 }

        escalationTask?.cancel()

        escalationTask = Task {
            while isRinging {

                try? await Task.sleep(nanoseconds: 1_500_000_000)

                guard isRinging else { break }

                hapticEngine.playBreathingWave(intensity: intensity)

                if intensity < 1.0 {
                    intensity += (1.0 - intensity) * 0.22
                }

                if let start = alarmStartTime {
                    let elapsed = Date().timeIntervalSince(start)

                    if elapsed > 15 && !soundStarted {
                        soundStarted = true
                        audioManager.play(soundName: soundID)
                        audioManager.fadeIn(duration: 5)
                    }
                }
            }
        }
    }

    func stopAlarm() {

        guard isRinging else { return }

        isRinging = false
        escalationTask?.cancel()

        hapticEngine.stop()
        audioManager.fadeOut(duration: 1.5)

        if let start = alarmStartTime {
            let responseTime = Date().timeIntervalSince(start)
            adaptBaseline(responseTime: responseTime)
        }
    }

    private func adaptBaseline(responseTime: TimeInterval) {

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
}
