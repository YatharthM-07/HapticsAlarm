

//
//  AudioManager.swift
//  HapticsAlarm
//

import Foundation
import AVFoundation

@MainActor
final class AudioManager {
    
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    private var volumeTimer: Timer?
    
    private init() {}
    
    // Play selected sound and gradually increase volume
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
            player?.volume = 0.05
            player?.play()
            
            startVolumeRamp()
            
        } catch {
            print("Audio error:", error)
        }
    }
    
    // Gradually increase volume
    private func startVolumeRamp() {
        
        volumeTimer?.invalidate()
        
        volumeTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            guard let player = self.player else { return }
            
            if player.volume < 1.0 {
                player.volume += 0.08
            }
        }
    }
    
    // Stop playback
    func stop() {
        volumeTimer?.invalidate()
        player?.stop()
        player = nil
    }
}
