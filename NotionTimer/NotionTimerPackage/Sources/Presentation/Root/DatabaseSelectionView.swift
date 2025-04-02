//
//  DatabaseSelectionView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/15.
//

import SwiftUI
import DataLayer
import Domain

struct DatabaseSelectionView: View {
    let notionService: NotionService
    
    @Environment(\.appServices) var appServices
    @State private var isLoading = true
    @State private var databases: [NotionDatabase] = []
    @State private var selectedDatabase: NotionDatabase?
    
    var body: some View {
        ZStack {
            List {
                NavigationLink {
                    DatabaseCreationView(notionService: appServices.notionService)
                } label: {
                    Text(String(moduleLocalized: "create-database-view-navigation-link"))
                }
  
                Section (
                    content: {
                        Picker("", selection: $selectedDatabase) {
                            ForEach(databases) { database in
                                Text("\(database.title)").tag(NotionDatabase?.some(database))
                            }
                            Text(String(moduleLocalized: "database-unselected"))
                                .tag(NotionDatabase?.none)
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .pickerStyle(NavigationLinkPickerStyle())
                    },
                    header: {
                        Text(String(moduleLocalized: "existing-database"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "existing-database-description"))
                    }
                )
            }
            
            CommonLoadingView()
                .hidden(!isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await fetchDatabases()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await fetchDatabases() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let selectedDatabaseID = selectedDatabase?.id else {
                        fatalError("ERROR: selectedDatabase が nil でも OK ボタンが押せている")
                    }
                    
                    Task {
                        do {
                            try await notionService.registerDatabase(id: selectedDatabaseID)
                        } catch {
                            debugPrint(error.localizedDescription) // TODO: ハンドリング
                        }
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(isLoading || selectedDatabase == nil)
            }
        }
    }
}

extension DatabaseSelectionView {
    private func fetchDatabases() async {
        isLoading = true
        do {
            let selectedDatabaseID = selectedDatabase?.id
            
            databases = try await notionService.getCompatibleDatabaseList()
            
            if let selectedDatabaseID = selectedDatabaseID {
                selectedDatabase = databases.first { $0.id == selectedDatabaseID }
            } else {
                selectedDatabase = nil
            }
        } catch {
            debugPrint("ERROR: ページ一覧の取得に失敗") // TODO: ハンドリング
        }
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        DatabaseSelectionView(notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue)
        )
    }
}
