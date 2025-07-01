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
            .rotationEffect(Angle(degrees: -90))
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

#Preview {
    TimerCircle(
        trimFrom: 0,
        trimTo: 0.99,
        color: .blue,
        strokeWidth: 80
    )
}
