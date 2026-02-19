import SwiftUI

struct NeonVortexProgress: View {
    
    var progress: CGFloat
    var size: CGFloat
    
    @State private var rotation1: Double = 0
    @State private var rotation2: Double = 0
    @State private var rotation3: Double = 0
    @State private var rotation4: Double = 0
    
    var body: some View {
        ZStack {
            
            // OUTER HEAVY RING
            vortexLayer(
                lineWidth: 28,
                trim: progress,
                colors: [.cyan, .white, .blue, .cyan],
                blur: 18,
                opacity: 1
            )
            .rotationEffect(.degrees(rotation1))
            
            // SECOND LAYER
            vortexLayer(
                lineWidth: 18,
                trim: progress,
                colors: [.white, .cyan],
                blur: 12,
                opacity: 0.95
            )
            .rotationEffect(.degrees(rotation2))
            
            // THIRD LAYER
            vortexLayer(
                lineWidth: 12,
                trim: progress,
                colors: [.cyan, .blue, .purple],
                blur: 8,
                opacity: 0.85
            )
            .rotationEffect(.degrees(rotation3))
            
            // CORE RING
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.white.opacity(0.9),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .blur(radius: 3)
        }
        .frame(width: size, height: size)
        .blendMode(.plusLighter)
        .onAppear {
            
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation1 = 360
            }
            
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation2 = -360
            }
            
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotation3 = 360
            }
            
            withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                rotation4 = -360
            }
        }
    }
    
    private func vortexLayer(
        lineWidth: CGFloat,
        trim: CGFloat,
        colors: [Color],
        blur: CGFloat,
        opacity: Double
    ) -> some View {
        
        Circle()
            .trim(from: 0, to: trim)
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
            .blur(radius: blur)
            .opacity(opacity)
    }
}
