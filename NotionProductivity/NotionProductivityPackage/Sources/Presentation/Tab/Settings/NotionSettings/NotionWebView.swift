import SwiftUI
import DataLayer
import Domain

struct NotionWebView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let notionService: NotionService
    private let notionLoginPageURL = URL(string: Bundle.main.object(forInfoDictionaryKey: "NOTION_OAUTH_URL") as! String)!
    private let scheme: String = Bundle.main.object(forInfoDictionaryKey: "SCHEME") as! String
    private let redirectHost: String = Bundle.main.object(forInfoDictionaryKey: "NOTION_REDIRECT_HOST") as! String
    private let redirectPath: String = Bundle.main.object(forInfoDictionaryKey: "NOTION_REDIRECT_PATH") as! String
    private let onAuthenticationComplete: (() async -> Void)?
    
    init(notionService: NotionService, onAuthenticationComplete: (() async -> Void)? = nil) {
        self.notionService = notionService
        self.onAuthenticationComplete = onAuthenticationComplete
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
        // DeepLink かチェック
        if url.scheme == scheme {
            guard let host = url.host,
                  let queryUrlComponents = URLComponents(string: url.absoluteString) else {
                return
            }
            
            // oauth ホストの場合
            if host == "oauth",
               let token = queryUrlComponents.queryItems?.first(where: { $0.name == "code" })?.value {
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
            return
        }
        
        // Redirect URL かチェック
        if url.host == redirectHost,
           url.path.contains(redirectPath),
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let _ = queryItems.first(where: { $0.name == "code" })?.value {
            
            // DeepLink を生成
            var deepLinkComponents = URLComponents()
            deepLinkComponents.scheme = scheme
            deepLinkComponents.host = "oauth"
            deepLinkComponents.queryItems = queryItems
            
            if let deepLinkURL = deepLinkComponents.url {
                await handleURLChange(deepLinkURL)
            }
        }
    }
}
