import SwiftUI

struct AlarmRingingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AlarmViewModel()
    
    let alarm: Alarm
    
    // Hold progress
    @State private var progress: Double = 0
    @State private var holdTimer: Timer?
    
    // UI state
    @State private var buttonPosition: CGPoint = .zero
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
            .animation(nil, value: progress)
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
            
            // Dark base
            Circle()
                .fill(Color.black.opacity(0.7))
                .frame(width: 190, height: 190)
            
            // Bloom halo
            Circle()
                .stroke(Color.cyan.opacity(0.8 * progress), lineWidth: 12)
                .blur(radius: 25)
                .frame(width: 190, height: 190)
            
            vortexLayer(
                trim: 0.35,
                lineWidth: 6,
                colors: [.cyan, .white, .blue],
                rotation: 1.2
            )
            
            vortexLayer(
                trim: 0.45,
                lineWidth: 4,
                colors: [.white, .cyan],
                rotation: -0.8
            )
            
            vortexLayer(
                trim: 0.25,
                lineWidth: 3,
                colors: [.cyan, .purple],
                rotation: 0.6
            )
            
            vortexLayer(
                trim: 0.15,
                lineWidth: 2,
                colors: [.white],
                rotation: -1.5
            )
            
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
    
    // MARK: Vortex Builder
    
    private func vortexLayer(
        trim: CGFloat,
        lineWidth: CGFloat,
        colors: [Color],
        rotation: Double
    ) -> some View {
        
        Circle()
            .trim(from: 0, to: trim * progress)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: colors),
                    center: .center
                ),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round
                )
            )
            .rotationEffect(.degrees(progress * 360 * rotation))
            .blendMode(.plusLighter)
            .blur(radius: 4)
            .opacity(progress)
            .frame(width: 190, height: 190)
    }
    
    // MARK: Hold Logic (5 seconds)
    
    private func startHoldProgress() {
        
        progress = 0
        
        holdTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            
            progress += 0.002  // 5 seconds total
            
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
        }
    }
    
    private func completeHold() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.stopAlarm()
            dismiss()
        }
    }
    
    // MARK: Safe Placement
    
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
