import DataLayer
import Observation

@MainActor @Observable public final class RecordViewModel {
    private let notionService: NotionService
    private let resultFocusTimeSec: Int
    
    public var description: String = ""
    public var tags: [NotionTag] = []
    public var selectedTags: Set<NotionTag> = []
    public var isLoading: Bool = true
    
    public init(notionService: NotionService, resultFocusTimeSec: Int) {
        self.notionService = notionService
        self.resultFocusTimeSec = resultFocusTimeSec
    }
    
    public func record() async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            try await notionService.record(
                time: resultFocusTimeSec,
                tags: Array(selectedTags),
                description: description
            )
            return
        } catch {
            throw error
        }
    }
    
    public func fetchDatabaseTags() async {
        isLoading = true
        do {
            tags = try await notionService.getDatabaseTags()
        } catch {
            debugPrint(error.localizedDescription) // TODO: ハンドリング
        }
        isLoading = false
    }
}
