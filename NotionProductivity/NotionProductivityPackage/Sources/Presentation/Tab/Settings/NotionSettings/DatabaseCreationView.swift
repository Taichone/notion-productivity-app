import SwiftUI
import DataLayer
import Domain

struct DatabaseCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: DatabaseSelectionViewModel
    
    init(viewModel: DatabaseSelectionViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Form {
                Section (
                    content: {
                        Picker("", selection: $viewModel.selectedParentPage) {
                            ForEach(viewModel.availableParentPages) { page in
                                Text("\(page.title)").tag(page)
                            }
                            Text(String(moduleLocalized: "no-parent-page-selected"))
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
                            text: $viewModel.newDatabaseTitle
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
            
            LoadingView()
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
                        await viewModel.createDatabase()
                        dismiss()
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(viewModel.newDatabaseTitle.isEmpty || viewModel.isLoading || viewModel.selectedParentPage == nil)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DatabaseCreationView(
            viewModel: .init(
                notionService: .init(
                    keychainClient: .testValue,
                    notionClient: .testValue,
                    notionAuthClient: .testValue
                )
            )
        )
    }
}
