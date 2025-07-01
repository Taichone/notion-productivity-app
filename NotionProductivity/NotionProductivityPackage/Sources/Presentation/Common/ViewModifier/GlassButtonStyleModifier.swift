import SwiftUI

struct GlassButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass)
        } else {
            content.buttonStyle(.plain)
        }
    }
}

extension View {
    func glassButtonStyle() -> some View {
        self.modifier(GlassButtonStyleModifier())
    }
}
