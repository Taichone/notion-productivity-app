import SwiftUI
import Charts
import DataLayer
import Domain

struct RecordDisplayView: View {
    @State private var viewModel: RecordDisplayViewModel
    private let chartViewID = UUID()
    
    init(notionService: NotionService) {
        self.viewModel = .init(notionService: notionService)
    }
    
    var body: some View {
        switch viewModel.notionAccessTokenStatus {
        case .notSelected:
            Text(String(moduleLocalized: "lets-connect-your-notion"))
            
        case .selected:
            switch viewModel.notionTimerRecordingDatabaseStatus {
            case .notSelected:
                Text(String(moduleLocalized: "select-your-database"))
                
            case .selected:
                ZStack {
                    ScrollViewReader { proxy in
                        ScrollView(.horizontal) {
                            Chart {
                                ForEach(viewModel.records) { record in
                                    BarMark(
                                        x: .value("Date", record.date, unit: .day),
                                        y: .value("Time", record.time)
                                    )
                                    .foregroundStyle(LinearGradient(
                                        gradient: Gradient(
                                            colors: viewModel.tagColors(from: record)
                                                .map { $0.color } // [NotionTag.Color] -> [Color]
                                        ),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ))
                                }
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day))
                            }
                            .padding()
                            .frame(width: viewModel.chartViewWidth)
                            .id(chartViewID)
                        }
                        .task {
                            await viewModel.fetchAllRecords()
                            proxy.scrollTo(chartViewID, anchor: .trailing) // 右端へスクロール
                        }
                    }
                    
                    LoadingView()
                        .hidden(!viewModel.isLoading)
                }
            }
        }
    }
}
