//
//  Copyright © 2025 Taichone. All rights reserved.
//
     
import SwiftUI
import DataLayer

@MainActor @Observable public final class DatabaseSelectionViewModel {
    private let notionService: NotionService
    public var isLoading = true
    
    // Database Selection Properties
    public var databases: [NotionDatabase] = []
    public var selectedDatabase: NotionDatabase?
    
    // New Database Creation Properties
    public var newDatabaseTitle: String = ""
    public var availableParentPages: [NotionPage] = []
    public var selectedParentPage: NotionPage?
    
    public init(notionService: NotionService) {
        self.notionService = notionService
    }
    
    public func fetchDatabases() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            databases = try await notionService.getCompatibleDatabaseList()
            if let selectedDatabaseID = selectedDatabase?.id {
                selectedDatabase = databases.first { $0.id == selectedDatabaseID }
            } else {
                selectedDatabase = nil
            }
        } catch {
            // TODO: ハンドリング
            debugPrint("ERROR: ページ一覧の取得に失敗")
        }
    }
    
    public func registerSelectedDatabase() async {
        guard let selectedDatabaseID = selectedDatabase?.id else {
            fatalError("ERROR: selectedDatabase が nil でも OK ボタンが押せている")
        }
        
        do {
            try await notionService.registerDatabase(id: selectedDatabaseID)
            await notionService.updateTimerRecordingDatabaseStatus()
        } catch {
            debugPrint(error.localizedDescription) // TODO: ハンドリング
        }
    }
    
    public func createDatabase() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            guard let selectedParentPageID = selectedParentPage?.id else {
                throw NotionServiceError.logicalError
            }
            
            // Request to create the database
            let createdDatabase = try await notionService.createDatabase(
                parentPageID: selectedParentPageID,
                title: newDatabaseTitle
            )
            
            // Select the database
            selectedDatabase = createdDatabase
            databases.append(createdDatabase)
            
            // Reset
            resetNewDatabaseCreation()
        } catch {
            
        }
    }
    
    public func fetchPages() async {
        isLoading = true
        defer {
            isLoading = false
        }
        
        do {
            let selectedPageID = selectedParentPage?.id
            availableParentPages = try await notionService.getPageList()
            if let selectedPageID = selectedPageID {
                selectedParentPage = availableParentPages.first {$0.id == selectedPageID }
            } else {
                selectedParentPage = nil
            }
        } catch {
            debugPrint("ERROR: ページ一覧の取得に失敗") // TODO: ハンドリング
        }
    }
    
    private func resetNewDatabaseCreation() {
        newDatabaseTitle = ""
        selectedParentPage = nil
    }
}
