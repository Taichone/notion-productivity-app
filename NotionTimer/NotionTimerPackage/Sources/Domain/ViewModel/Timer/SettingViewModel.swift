import DataLayer
import Observation

@MainActor @Observable public final class SettingViewModel {
    private let notionService: NotionService
    
    public init(notionService: NotionService) {
        self.notionService = notionService
    }
    
    public func reselectDatabase() async {
        do {
            try await notionService.releaseDatabase()
        } catch {
            // TODO: ハンドリング
            debugPrint(error)
        }
    }
    
    public func logout() async {
        do {
            try await notionService.releaseAccessTokenAndDatabase()
        } catch {
            // TODO: ハンドリング
            debugPrint(error)
        }
    }
}

