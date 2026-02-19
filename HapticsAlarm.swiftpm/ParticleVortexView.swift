//
//  ParticleVortexView.swift
//  HapticsAlarm
//
//  Created by GEU on 19/02/26.
//

import SwiftUI
import UIKit

struct ParticleVortexView: UIViewRepresentable {
    
    var progress: CGFloat
    var isActive: Bool
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        let emitter = CAEmitterLayer()
        emitter.emitterShape = .circle
        emitter.emitterMode = .outline
        emitter.emitterSize = CGSize(width: 170, height: 170)
        emitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.contents = generateParticleImage()
        cell.birthRate = 120
        cell.lifetime = 1.2
        cell.velocity = 40
        cell.scale = 0.015
        cell.alphaSpeed = -0.8
        cell.emissionRange = .pi * 2
        
        emitter.emitterCells = [cell]
        
        view.layer.addSublayer(emitter)
        context.coordinator.emitter = emitter
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let emitter = context.coordinator.emitter else { return }
        
        emitter.emitterPosition = CGPoint(x: uiView.bounds.midX,
                                          y: uiView.bounds.midY)
        
        emitter.birthRate = isActive ? 1 : 0
        
        emitter.emitterCells?.first?.birthRate = isActive ? 120 : 0
        
        // Progress controls emission angle mask
        let angle = progress * .pi * 2
        emitter.emitterCells?.first?.emissionLongitude = angle
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var emitter: CAEmitterLayer?
    }
    
    private func generateParticleImage() -> CGImage {
        let size = CGSize(width: 10, height: 10)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fillEllipse(in: rect)
        }
        
        return image.cgImage!
    }
   

}
