import DataLayer
import Observation

@MainActor @Observable public final class SettingsViewModel {
    public let notionService: NotionService
    public var notionAccessTokenStatus: NotionAccessTokenStatus = .notSelected
    public var notionTimerRecordingDatabaseStatus: NotionTimerRecordingDatabaseStatus = .notSelected
    
    public init(notionService: NotionService) {
        self.notionService = notionService
        Task {
            await fetchNotionStatus()
            print("NotionSettingsViewModel.init - fetchNotionStatus")
        }
    }
    
    public func logout() async {
        do {
            try await notionService.logout()
        } catch {
            // TODO: ハンドリング
            debugPrint(error)
        }
        await fetchNotionStatus()
    }
    
    public func onAppear() async {
        await fetchNotionStatus()
    }
    
    private func fetchNotionStatus() async {
        notionAccessTokenStatus  = await notionService.accessTokenStatus
        notionTimerRecordingDatabaseStatus = await notionService.timerRecordingDatabaseStatus
    }
}
