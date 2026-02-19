import SwiftUI

struct AlarmRingingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AlarmViewModel()
    
    let alarm: Alarm
    
    // Hold progress
    @State private var progress: Double = 0
    @State private var holdTimer: Timer?
    
    // Wave animation phases
    @State private var phase1: Double = 0
    @State private var phase2: Double = 0
    @State private var phase3: Double = 0
    
    // UI state
    @State private var buttonPosition: CGPoint = .zero
    @State private var glowOpacity: Double = 0
    @State private var backgroundPulse: Double = 0.28
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Neon breathing background
                Color.black
                    .overlay(
                        RadialGradient(
                            colors: [
                                Color.cyan.opacity(backgroundPulse),
                                Color.blue.opacity(backgroundPulse * 0.8),
                                Color.indigo.opacity(backgroundPulse * 0.5),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 900
                        )
                        .blur(radius: 200)
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 1.8), value: backgroundPulse)
                
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text(alarm.time, style: .time)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.white)
                    
                    Text(alarm.label)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Spacer()
                    
                    // Reactive center glow
                    Circle()
                        .fill(Color.cyan.opacity(Double(viewModel.intensity)))
                        .frame(
                            width: 140 + CGFloat(viewModel.intensity * 160),
                            height: 140 + CGFloat(viewModel.intensity * 160)
                        )
                        .blur(radius: 70)
                        .animation(.easeInOut(duration: 1.2), value: viewModel.intensity)
                    
                    Spacer()
                }
            }
            .animation(nil, value: progress) // prevent layout shift
            .overlay(
                holdButton
                    .position(buttonPosition)
            )
            .onAppear {
                viewModel.startAlarm(soundID: alarm.soundID)
                generateRandomPosition(in: geometry.size)
            }
            .onDisappear {
                viewModel.stopAlarm()
            }
        }
    }
    
    // MARK: Stop Button
    
    private var holdButton: some View {
        ZStack {
            
            // Outer glow
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.cyan,
                            Color.blue,
                            Color.white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .blur(radius: 10)
                .opacity(glowOpacity)
                .frame(width: 170, height: 170)
            
            // Wave Layer 1
            WaveRingShape(
                progress: progress,
                phase: phase1,
                amplitude: 8,
                frequency: 11
            )
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color.cyan,
                        Color.white,
                        Color.blue,
                        Color.cyan
                    ]),
                    center: .center
                ),
                lineWidth: 3
            )
            .blur(radius: 2)
            .frame(width: 170, height: 170)
            
            // Wave Layer 2
            WaveRingShape(
                progress: progress,
                phase: phase2,
                amplitude: 10,
                frequency: 15
            )
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.8),
                        Color.cyan,
                        Color.blue
                    ]),
                    center: .center
                ),
                lineWidth: 2
            )
            .blur(radius: 1.5)
            .frame(width: 170, height: 170)
            
            // Wave Layer 3
            WaveRingShape(
                progress: progress,
                phase: phase3,
                amplitude: 4,
                frequency: 30
            )

            .stroke(
                Color.white.opacity(0.8),
                lineWidth: 1.5
            )
            .frame(width: 170, height: 170)
            
            Text("Hold to Stop")
                .foregroundColor(.white)
                .font(.headline)
        }
        .gesture(
            LongPressGesture(minimumDuration: 5)
                .onChanged { _ in
                    if holdTimer == nil {
                        startHoldProgress()
                    }
                }
                .onEnded { _ in
                    cancelHold()
                }
        )
    }
    
    // MARK: Hold Logic (5 seconds)
    
    private func startHoldProgress() {
        
        glowOpacity = 1
        progress = 0
        
        // Animate wave phases
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            phase1 = 360
        }
        withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
            phase2 = -360
        }
        withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
            phase3 = 360
        }
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            progress += 0.002   // 5 seconds total
            
            if progress >= 1 {
                timer.invalidate()
                holdTimer = nil
                completeHold()
            }
        }
    }
    
    private func cancelHold() {
        holdTimer?.invalidate()
        holdTimer = nil
        
        withAnimation(.easeOut(duration: 0.3)) {
            progress = 0
            glowOpacity = 0
        }
        
        phase1 = 0
        phase2 = 0
        phase3 = 0
    }
    
    private func completeHold() {
        
        withAnimation(.easeIn(duration: 0.2)) {
            glowOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.stopAlarm()
            dismiss()
        }
    }
    
    // MARK: Safe Button Placement
    
    private func generateRandomPosition(in size: CGSize) {
        
        let radius: CGFloat = 95
        let padding = radius + 20
        
        let minX = padding
        let maxX = size.width - padding
        
        let minY = size.height * 0.42
        let maxY = size.height - 120
        
        buttonPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
}
