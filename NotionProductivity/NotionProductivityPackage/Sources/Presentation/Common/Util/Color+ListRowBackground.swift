import SwiftUI

extension Color {
    static var listRowBackground: Color {
        Color(UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor.secondarySystemBackground
            } else {
                return UIColor.systemBackground
            }
        })
    }
}
