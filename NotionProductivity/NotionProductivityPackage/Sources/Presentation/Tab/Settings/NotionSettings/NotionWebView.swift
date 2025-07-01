import SwiftUI
import DataLayer
import Domain

struct NotionWebView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let notionService: NotionService
    private let notionLoginPageURL: URL
    private let onAuthenticationComplete: (() async -> Void)?
    
    init(notionService: NotionService, onAuthenticationComplete: (() async -> Void)? = nil) {
        self.notionService = notionService
        self.onAuthenticationComplete = onAuthenticationComplete
        let oauthURLString = Bundle.main.object(forInfoDictionaryKey: "NOTION_OAUTH_URL") as! String
        self.notionLoginPageURL = URL(string: oauthURLString)!
    }
    
    var body: some View {
        NavigationStack {
            WebView(
                url: notionLoginPageURL,
                onURLChange: { url in
                    Task {
                        await handleURLChange(url)
                    }
                }
            )
            .navigationTitle(String(moduleLocalized: "connect-your-notion"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(moduleLocalized: "cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func handleURLChange(_ url: URL) async {
        if let deeplink = url.getDeeplink() {
            switch deeplink {
            case .notionTemporaryToken(let token):
                do {
                    // TODO: ローディング中 UIを表示
                    try await notionService.fetchAccessToken(temporaryToken: token)
                    await notionService.updateAccessTokenStatus()
                    await onAuthenticationComplete?()
                    await MainActor.run {
                        dismiss()
                    }
                } catch {
                    // TODO: アラートを表示（アクセストークンの取得に失敗）
                    debugPrint(error)
                }
            }
        }
    }
}

private extension URL {
    enum Deeplink {
        case notionTemporaryToken(token: String)
    }
    
    func getDeeplink() -> Deeplink? {
        let scheme = Bundle.main.object(forInfoDictionaryKey: "SCHEME") as! String
        guard scheme == scheme,
              let host = host,
              let queryUrlComponents = URLComponents(string: absoluteString) else {
            return nil
        }
        
        switch host {
        case "oauth":
            if let notionTemporaryToken = queryUrlComponents.getParameterValue(for: "code") {
                return Deeplink.notionTemporaryToken(token: notionTemporaryToken)
            }
        default:
            break
        }
        return nil
    }
}

private extension URLComponents {
    func getParameterValue(for parameter: String) -> String? {
        queryItems?.first(where: { $0.name == parameter })?.value
    }
}
