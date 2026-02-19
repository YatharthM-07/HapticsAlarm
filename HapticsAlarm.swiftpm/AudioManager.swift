import Foundation
import AVFoundation

@MainActor
final class AudioManager {
    
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    private var volumeTimer: Timer?
    
    private init() {}
    
    // MARK: Play
    
    func play(soundName: String) {
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file not found:", soundName)
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.0
            player?.prepareToPlay()
            player?.play()
            
        } catch {
            print("Audio error:", error)
        }
    }
    
    // MARK: Smooth Fade In
    
    func fadeIn(duration: TimeInterval = 5) {
        
        guard let player = player else { return }
        
        volumeTimer?.invalidate()
        
        let stepInterval: TimeInterval = 0.05
        let steps = duration / stepInterval
        let volumeStep = 1.0 / Float(steps)
        
        volumeTimer = Timer.scheduledTimer(withTimeInterval: stepInterval,
                                           repeats: true) { [weak self] timer in
            
            guard let self else { return }
            guard let player = self.player else { return }
            
            if player.volume < 1.0 {
                player.volume += volumeStep
            } else {
                player.volume = 1.0
                timer.invalidate()
            }
        }
        
        RunLoop.main.add(volumeTimer!, forMode: .common)
    }
    
    // MARK: Smooth Fade Out
    
    func fadeOut(duration: TimeInterval = 1.5) {
        
        guard let player = player else { return }
        
        volumeTimer?.invalidate()
        
        let stepInterval: TimeInterval = 0.05
        let steps = duration / stepInterval
        let volumeStep = player.volume / Float(steps)
        
        volumeTimer = Timer.scheduledTimer(withTimeInterval: stepInterval,
                                           repeats: true) { [weak self] timer in
            
            guard let self else { return }
            guard let player = self.player else { return }
            
            if player.volume > 0 {
                player.volume -= volumeStep
            } else {
                player.volume = 0
                player.stop()
                self.player = nil
                timer.invalidate()
                
                try? AVAudioSession.sharedInstance().setActive(false)
            }
        }
        
        RunLoop.main.add(volumeTimer!, forMode: .common)
    }
    
    // MARK: Immediate Stop (Emergency)
    
    func stop() {
        volumeTimer?.invalidate()
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
