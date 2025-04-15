//
//  Color+InitWithHex.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/15.
//

import SwiftUI

extension Color {
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
}
