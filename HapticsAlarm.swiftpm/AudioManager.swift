import Foundation
import AVFoundation

@MainActor
final class AudioManager {
    
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    private var volumeTimer: Timer?
    
    private init() {}
    
  
    
    func play(soundName: String) {
        guard let data = SoundAssets.data(for: soundName) else {
            print(" Sound not found:", soundName)
            return
        }
        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: data)
            player?.numberOfLoops = -1
            player?.volume = 0.0
            player?.prepareToPlay()
            player?.play()
        } catch {
            print(" Audio error:", error)
        }
    }
    
   
    
    func fadeIn(duration: TimeInterval = 8) {
        
        guard let player = player else { return }
        
        player.volume = 0.0
        volumeTimer?.invalidate()
        
        let stepInterval: TimeInterval = 0.05
        let steps = duration / stepInterval
        let volumeStep = 1.0 / Float(steps)
        
        volumeTimer = Timer.scheduledTimer(
            withTimeInterval: stepInterval,
            repeats: true
        ) { [weak self] timer in
            
            guard let self, let player = self.player else {
                timer.invalidate()
                return
            }
            
            if player.volume < 1.0 {
                player.volume = min(player.volume + volumeStep, 1.0)
            } else {
                player.volume = 1.0
                timer.invalidate()
            }
        }
        
        RunLoop.main.add(volumeTimer!, forMode: .common)
    }
    
    
    
    func fadeOut(duration: TimeInterval = 1.5) {
        
        guard let player = player else { return }
        
        volumeTimer?.invalidate()
        
        let stepInterval: TimeInterval = 0.05
        let steps = duration / stepInterval
        let volumeStep = player.volume / Float(steps)
        
        volumeTimer = Timer.scheduledTimer(
            withTimeInterval: stepInterval,
            repeats: true
        ) { [weak self] timer in
            
            guard let self, let player = self.player else {
                timer.invalidate()
                return
            }
            
            if player.volume > 0 {
                player.volume = max(player.volume - volumeStep, 0)
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
    
    
    
    func stop() {
        volumeTimer?.invalidate()
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
