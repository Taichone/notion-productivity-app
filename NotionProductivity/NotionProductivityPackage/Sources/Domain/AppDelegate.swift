import SwiftUI
import DataLayer

@MainActor
public final class AppDelegate: NSObject, UIApplicationDelegate {
    public let appDependencies = AppDependenciesKey.defaultValue
    public let appServices = AppServicesKey.defaultValue

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // アプリケーション起動時の初期化処理
        return true
    }

    public func applicationWillTerminate(_ application: UIApplication) {
        // アプリケーション終了時の処理
    }
}
