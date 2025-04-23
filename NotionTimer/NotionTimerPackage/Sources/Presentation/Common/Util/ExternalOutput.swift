//
//  ExternalFeedback.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/07.
//

import UIKit.UIImpactFeedbackGenerator

struct ExternalOutput {
    @MainActor static func tapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
