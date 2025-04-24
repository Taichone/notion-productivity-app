import Foundation
import Observation
import DataLayer

@MainActor @Observable public final class RootViewModel {
    private let notionService: NotionService
    public var authStatus: NotionAuthStatus
    
    public init(notionService: NotionService) {
        self.authStatus = .loading
        self.notionService = notionService
    }
    
    public func onAppear() async {
        await notionService.fetchAuthStatus()
        authStatus = await notionService.authStatus
    }
    
    public func onOpenURL(_ url: URL) async {
        if let deeplink = url.getDeeplink() {
            switch deeplink {
            case .notionTemporaryToken(let token):
                Task {
                    do {
                        try await notionService.fetchAccessToken(temporaryToken: token)
                        await notionService.fetchAuthStatus()
                        authStatus = await notionService.authStatus
                    } catch {
                        // TODO: アラートを表示（アクセストークンの取得に失敗）
                        debugPrint(error)
                    }
                }
            }
        }
    }
}
