import SwiftUI
import DataLayer
import Domain

struct RecordView: View {
    @State private var viewModel: RecordViewModel
    @EnvironmentObject private var router: NavigationRouter
    
    init(dependency: Dependency, notionService: NotionService) {
        self.viewModel = .init(
            notionService: notionService, 
            resultFocusTimeSec: dependency.resultFocusTimeSec
        )
    }
    
    var body: some View {
        ZStack {
            List(selection: $viewModel.selectedTags) {
                Group {
                    Section (
                        content: {
                            TextEditor(text: $viewModel.description)
                                .frame(height: 100)
                        },
                        header: {
                            Text(String(moduleLocalized: "record-description"))
                        },
                        footer: {
                            Text(String(moduleLocalized: "record-description-description"))
                        }
                    )
                }
                
                Section (
                    content: {
                        ForEach(viewModel.tags) { tag in
                            Text(tag.name)
                                .tag(tag)
                                .listRowBackground(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .listRowBackground,
                                            .listRowBackground,
                                            tag.color.color
                                        ]),
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                        }
                    },
                    header: {
                        Text(String(moduleLocalized: "tag"))
                    },
                    footer: {
                        Text(String(moduleLocalized: "tag-description"))
                    }
                )
            }
            .environment(\.editMode, .constant(.active))
            
            LoadingView()
                .hidden(!viewModel.isLoading)
        }
        .navigationTitle(String(moduleLocalized: "timer-record-view-navigation-title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // TODO: 初回読み込みのタイミングは UX に考慮して再検討
            await viewModel.fetchDatabaseTags()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task { await viewModel.fetchDatabaseTags() }
                } label: {
                    Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.record()
                        router.items.removeAll()
                    }
                } label: {
                    Text(String(moduleLocalized: "ok"))
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
}

extension RecordView {
    struct Dependency: Hashable {
        let resultFocusTimeSec: Int
    }
}

#Preview {
    RecordView(
        dependency: .init(resultFocusTimeSec: 3661),
        notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue
        )
    )
}
