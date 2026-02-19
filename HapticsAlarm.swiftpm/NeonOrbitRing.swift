import SwiftUI

struct NeonOrbitRing: View {
    
    let dash: [CGFloat]
    let lineWidth: CGFloat
    let colors: [Color]
    let rotation: Double
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: colors),
                    center: .center
                ),
                style: StrokeStyle(
                    lineWidth: lineWidth,
                    lineCap: .round,
                    dash: dash
                )
            )
            .blur(radius: 1.4)
            .rotationEffect(.degrees(rotation))
            .frame(width: size, height: size)
    }
}
