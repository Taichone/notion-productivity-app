import UIKit.UIImpactFeedbackGenerator

struct ExternalOutput {
    @MainActor static func tapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
