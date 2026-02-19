//
//  WaveRingShape.swift
//  HapticsAlarm
//
//  Created by GEU on 19/02/26.
//

import SwiftUI

struct WaveRingShape: Shape {
    
    var progress: Double
    var phase: Double
    var amplitude: CGFloat
    var frequency: CGFloat
    
    func path(in rect: CGRect) -> Path {
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let baseRadius = min(rect.width, rect.height) / 2
        
        var path = Path()
        
        let maxAngle = progress * 360
        let steps = 400
        
        for step in 0...steps {
            
            let angle = Double(step) / Double(steps) * maxAngle
            let radians = angle * .pi / 180
            
            let wave = sin(CGFloat(angle) * frequency * .pi / 180 + phase)
            let radius = baseRadius + wave * amplitude
            
            let x = center.x + cos(radians) * radius
            let y = center.y + sin(radians) * radius
            
            if step == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}
