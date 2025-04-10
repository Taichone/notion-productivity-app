//
//  DatabaseCreationView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/16.
//

import SwiftUI
import DataLayer
import Domain

@MainActor @Observable public final class DatabaseCreationViewModel {
    private let notionService: NotionService
    
    public var isLoading: Bool = true
    public var title: String = ""
    public var pages: [NotionPage] = []
    public var selectedParentPage: NotionPage?
    
    public init(notionService: NotionService) {
        self.notionService = notionService
    }
    
    public  func createDatabase() async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        
        guard let selectedParentPageID = selectedParentPage?.id else {
            throw NotionServiceError.parentPageIsNotSelected
        }
        try await notionService.createDatabase(
            parentPageID: selectedParentPageID,
            title: title
        )
    }
    
    public func fetchPages() async {
        isLoading = true
        do {
            let selectedPageID = selectedParentPage?.id
            
            pages = try await notionService.getPageList()
            
            if let selectedPageID = selectedPageID {
                selectedParentPage = pages.first { $0.id == selectedPageID }
            } else {
                selectedParentPage = nil
            }
        } catch {
            debugPrint("ERROR: ページ一覧の取得に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
}

struct DatabaseCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: DatabaseCreationViewModel
    
    init(notionService: NotionService) {
        self.viewModel = .init(notionService: notionService)
    }
    
    var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $viewModel.selectedParentPage) {
                            ForEach(viewModel.pages) { page in
                                Text("\(page.title)").tag(page)
                            }
                            Text(String(moduleLocalized: "parent-page-unselected"))
                                .tag(NotionPage?.none)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "parent-page"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "parent-page-description"))
                    }
                )
                
                Section (
                    content: {
                        TextField(
                            String(moduleLocalized: "new-database-title-text-field-spaceholder"),
                            text: $viewModel.title
                        )
                    },
                    header: {
                        Text(String(moduleLocalized: "new-database-title"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "new-database-title-description"))
                    }
                )
            }
            
            CommonLoadingView()
                .hidden(!viewModel.isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-creation-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await viewModel.fetchPages()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.fetchPages() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        do {
                            try await viewModel.createDatabase()
                            dismiss()
                        } catch {
                            
                        }
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(viewModel.title.isEmpty || viewModel.isLoading || viewModel.selectedParentPage == nil)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseCreationView(notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue
        ))
    }
}
