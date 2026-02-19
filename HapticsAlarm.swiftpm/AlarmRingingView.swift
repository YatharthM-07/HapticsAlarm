import SwiftUI

struct AlarmRingingView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AlarmViewModel()
    
    let alarm: Alarm
    
    @State private var progress: CGFloat = 0
    @State private var buttonPosition: CGPoint = .zero
    @State private var backgroundPulse: Double = 0.28
    
    var body: some View {
        GeometryReader { geometry in
            
            ZStack {
                
                // Background – neon breathing glow
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
                
                VStack(spacing: 20) {
                    
                    Spacer()
                    
                    Text(alarm.time, style: .time)
                        .font(.system(size: 64, weight: .thin))
                        .foregroundColor(.white)
                    
                    Text(alarm.label)
                        .foregroundStyle(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.cyan.opacity(Double(viewModel.intensity)))
                        .frame(
                            width: 140 + CGFloat(viewModel.intensity * 160),
                            height: 140 + CGFloat(viewModel.intensity * 160)
                        )
                        .blur(radius: 70)
                        .animation(.easeInOut(duration: 1.2),
                                   value: viewModel.intensity)
                    
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
                
                withAnimation(.easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)) {
                    backgroundPulse = 0.38
                }
            }
            .onDisappear {
                viewModel.stopAlarm()
            }
        }
    }
    
    private var holdButton: some View {

        ZStack {

            Circle()
                .fill(Color.black.opacity(0.75))
                .frame(width: 220, height: 220)

            NeonVortexProgress(
                progress: progress,
                size: 220
            )

            Text("Hold to Stop")
                .foregroundColor(.white)
                .font(.headline)
        }
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if progress == 0 {
                        startHold()
                    }
                }
                .onEnded { _ in
                    cancelHold()
                }
        )
    }

    @State private var holdTask: Task<Void, Never>?

    private func startHold() {

        holdTask?.cancel()

        progress = 0

        holdTask = Task {

            let duration: Double = 5
            let steps = 100
            let stepTime = duration / Double(steps)

            for i in 0...steps {

                try? await Task.sleep(
                    nanoseconds: UInt64(stepTime * 1_000_000_000)
                )

                await MainActor.run {
                    progress = CGFloat(i) / CGFloat(steps)
                }

                if Task.isCancelled { return }
            }

            await MainActor.run {
                completeHold()
            }
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        holdTask = nil

        withAnimation(.easeOut(duration: 0.25)) {
            progress = 0
        }
    }

    
    private func completeHold() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            viewModel.stopAlarm()
            dismiss()
        }
    }
    
    private func generateRandomPosition(in size: CGSize) {
        
        let radius: CGFloat = 110
        let padding = radius + 20
        
        let minX = padding
        let maxX = size.width - padding
        
        let minY = size.height * 0.45
        let maxY = size.height - 150
        
        buttonPosition = CGPoint(
            x: CGFloat.random(in: minX...maxX),
            y: CGFloat.random(in: minY...maxY)
        )
    }
}
