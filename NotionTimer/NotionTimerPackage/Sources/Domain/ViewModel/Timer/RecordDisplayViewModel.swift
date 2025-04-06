//
//  RecordDisplayViewModel.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/06.
//

import DataLayer
import Observation
import SwiftUI

@MainActor @Observable public final class RecordDisplayViewModel {
    private let notionService: NotionService
    public var records: [Record] = []
    public var isLoading = true
    
    public init(notionService: NotionService) {
        self.notionService = notionService
    }
    
    public func fetchAllRecords() async {
        do {
            isLoading = true
            records = try await notionService.getAllRecords()
            isLoading = false
        } catch {
            debugPrint("ERROR: 記録の取得に失敗") // TODO: ハンドリング
        }
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
