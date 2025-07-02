import DataLayer
import Observation
import SwiftUI

@MainActor @Observable public final class RecordDisplayViewModel {
    private let notionService: NotionService
    public var notionAccessTokenStatus: NotionAccessTokenStatus = .notSelected
    public var notionTimerRecordingDatabaseStatus: NotionDatabaseStatus = .notSelected
    public var records: [Record] = []
    public var isLoading = true
    
    public init(notionService: NotionService) {
        self.notionService = notionService
        Task {
            await fetchNotionStatus()
        }
    }
    
    public func fetchAllRecords() async {
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            records = try await notionService.getFilteredRecords()
        } catch {
            // TODO: ハンドリング
            debugPrint(error)
            await notionService.updateTimerRecordingDatabaseStatus()
        }
    }
    
    private func fetchNotionStatus() async {
        notionAccessTokenStatus  = await notionService.accessTokenStatus
        notionTimerRecordingDatabaseStatus = await notionService.timerRecordingDatabaseStatus
    }
    
    public func tagColors(from record: Record) -> [NotionTag.Color] {
        guard !record.tags.isEmpty else {
            return [NotionTag.Color.default]
        }
        return record.tags.map { $0.color }
    }
    
    public var chartViewWidth: CGFloat {
        let uniqueDates = Set(records.map { record in
            Calendar.current.startOfDay(for: record.date)
        })
        
        return CGFloat(uniqueDates.count * 100)
    }
}
