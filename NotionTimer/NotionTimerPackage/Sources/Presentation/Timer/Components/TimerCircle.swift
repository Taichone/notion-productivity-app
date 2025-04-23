//
//  TimerCircle.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI

struct TimerCircle: View {
    let trimFrom: CGFloat
    let trimTo: CGFloat
    let color: Color
    let strokeWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: trimFrom, to: trimTo)
            .stroke(
                color,
                style: StrokeStyle(
                    lineWidth: strokeWidth,
                    lineCap: .butt,
                    lineJoin: .miter
                )
            )
            .scaledToFit()
            .padding(strokeWidth / 2)
    }
    
    static func background(color: Color, strokeWidth: CGFloat) -> Self {
        .init(
            trimFrom: 0,
            trimTo: 1,
            color: color,
            strokeWidth: strokeWidth
        )
    }
}

struct TimerCenterCircle: View {
    let color: Color
    let strokeWidth: CGFloat
    
    var body: some View {
        Circle()
            .fill(color)
            .padding(strokeWidth)
    }
}
