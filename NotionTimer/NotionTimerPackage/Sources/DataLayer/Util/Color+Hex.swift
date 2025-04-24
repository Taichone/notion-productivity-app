import SwiftUI

public extension Color {
    init(hex: String, opacity: CGFloat = 1.0) {
        let hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        guard hexFormatted.count == 6 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        var rgbValue: UInt64 = 0
        guard Scanner(string: hexFormatted).scanHexInt64(&rgbValue) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }

        self.init(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double((rgbValue & 0x0000FF)) / 255.0,
            opacity: opacity
        )
    }
    
    var hexString: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
}
