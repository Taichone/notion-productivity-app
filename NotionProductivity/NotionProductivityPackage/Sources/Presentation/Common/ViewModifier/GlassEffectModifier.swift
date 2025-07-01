//
//  Copyright © 2025 Taichone. All rights reserved.
//


import SwiftUI

struct GlassEffectModifier<S: Shape>: ViewModifier {
    let tintColor: Color?
    let interactive: Bool
    let shape: S
    let enabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            let glass = Glass.regular
                .tint(tintColor)
                .interactive(interactive)
            content.glassEffect(glass, in: shape, isEnabled: enabled)
        } else {
            content
        }
    }
}

extension View {
    func glassEffectIfAvailable<S: Shape>(
        tint: Color? = nil,
        interactive: Bool = false,
        in shape: S = Capsule(),
        isEnabled: Bool = true
    ) -> some View {
        modifier(
            GlassEffectModifier(
                tintColor: tint,
                interactive: interactive,
                shape: shape,
                enabled: isEnabled
            )
        )
    }
}
