import SwiftUI

struct AlarmRingingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AlarmViewModel()
    
    let alarm: Alarm
    
    @State private var progress: Double = 0
    @State private var buttonPosition: CGPoint = .zero
    
    @State private var isPressing = false
    @State private var holdTimer: Timer?
    
    @State private var glowOpacity: Double = 0
    @State private var backgroundPulse: Double = 0.15
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Breathing background
                Color.black
                    .overlay(
                        Circle()
                            .fill(Color.blue.opacity(backgroundPulse))
                            .scaleEffect(1.6)
                            .blur(radius: 140)
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 2), value: backgroundPulse)
                
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text(alarm.time, style: .time)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.white)
                    
                    Text(alarm.label)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.blue.opacity(Double(viewModel.intensity)))
                        .frame(
                            width: 140 + CGFloat(viewModel.intensity * 160),
                            height: 140 + CGFloat(viewModel.intensity * 160)
                        )
                        .blur(radius: 60)
                        .animation(.easeInOut(duration: 1.2), value: viewModel.intensity)
                    
                    Spacer()
                }
            }
            .overlay(
                holdButton
                    .position(buttonPosition)
            )
            .onAppear {
                viewModel.startAlarm(soundID: alarm.soundID)
                generateRandomPosition(in: geometry.size)
                animateBackground()
            }
            .onDisappear {
                viewModel.stopAlarm()
            }
        }
    }
    
    // MARK: Electric Stop Button
    
    private var holdButton: some View {
        ZStack {
            
            // Neon glow layer
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.blue,
                            Color.cyan,
                            Color.white
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 6
                )
                .blur(radius: isPressing ? 8 : 0)
                .opacity(glowOpacity)
                .frame(width: 170, height: 170)
            
            // Rotating segmented energy ring
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color.white,
                            Color.blue,
                            Color.cyan,
                            Color.white
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [12, 18])
                )
                .rotationEffect(.degrees(rotation))
                .frame(width: 170, height: 170)
            
            // Inner base circle
            Circle()
                .stroke(Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 150, height: 150)
            
            // Hold progress ring
            Circle()
                .trim(from: 0, to: holdProgress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 150, height: 150)
                .animation(.linear(duration: 2), value: holdProgress)
            
            Text("Hold to Stop")
                .foregroundColor(.white)
                .font(.headline)
        }
        .gesture(
            LongPressGesture(minimumDuration: 2)
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
    
    // MARK: Electric Animation
    
    private func startElectricAnimation() {
        isPressing = true
        glowOpacity = 1
        
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotation = 360
        }
    }
    
    private func stopElectricAnimation() {
        isPressing = false
        
        withAnimation(.easeOut(duration: 0.3)) {
            glowOpacity = 0
            rotation = 0
        }
    }
    
    // MARK: Safe Random Position
    
    private func generateRandomPosition(in size: CGSize) {
        
        let buttonRadius: CGFloat = 85
        let horizontalPadding: CGFloat = buttonRadius + 20
        
        let topUnsafeHeight: CGFloat = size.height * 0.35
        let bottomUnsafeHeight: CGFloat = size.height - 120
        
        let minX = horizontalPadding
        let maxX = size.width - horizontalPadding
        
        let minY = topUnsafeHeight
        let maxY = bottomUnsafeHeight
        
        buttonPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
    
    // MARK: Background Pulse
    
    private func animateBackground() {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            withAnimation {
                backgroundPulse = backgroundPulse == 0.15 ? 0.3 : 0.15
            }
        }
    }
}
