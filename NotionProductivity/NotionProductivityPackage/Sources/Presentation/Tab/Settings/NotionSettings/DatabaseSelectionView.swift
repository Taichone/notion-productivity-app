import SwiftUI
import DataLayer
import Domain

struct DatabaseSelectionView: View {
    @State private var viewModel: DatabaseSelectionViewModel
    @State private var isPresentingCreation = false
    @Environment(\.dismiss) private var dismiss
    
    init(notionService: NotionService) {
        self.viewModel = .init(notionService: notionService)
    }
    
    var body: some View {
        ZStack {
            List {
                Button {
                    isPresentingCreation = true
                } label: {
                    Text(String(moduleLocalized: "create-database-view-navigation-link"))
                }
  
                Section (
                    content: {
                        Picker("", selection: $viewModel.selectedDatabase) {
                            ForEach(viewModel.databases) { database in
                                Text("\(database.title)").tag(NotionDatabase?.some(database))
                            }
                            Text(String(moduleLocalized: "no-database-selected"))
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
            
            LoadingView()
                .hidden(!viewModel.isLoading)
        }
        .navigationTitle(String(moduleLocalized: "database-selection-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await viewModel.fetchDatabases()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.fetchDatabases()
                    }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.registerSelectedDatabase()
                        dismiss()
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(viewModel.isLoading || viewModel.selectedDatabase == nil)
            }
        }
        .sheet(isPresented: $isPresentingCreation) {
            NavigationStack {
                DatabaseCreationView(viewModel: viewModel)
            }
        }
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
