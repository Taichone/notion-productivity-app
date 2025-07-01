import SwiftUI
import Presentation
import Domain

@main
struct NotionProductivityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        RootScene()
    }
}

fileprivate struct PreferredLanguageSettingValidator {
    fileprivate let language = String(localized: "language")
}
