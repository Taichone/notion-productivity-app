//
//  RecordDisplayView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/12/03.
//

import SwiftUI
import Charts
import DataLayer
import Domain

struct RecordDisplayView: View {
    @State private var viewModel: RecordDisplayViewModel
    private let chartViewID = UUID()
    
    init(notionService: NotionService) {
        self.viewModel = RecordDisplayViewModel(notionService: notionService)
    }
    
    var body: some View {
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
                    .frame(height: 200)
                    .padding()
                    .frame(width: viewModel.chartViewWidth)
                    .id(chartViewID)
                }
                .task {
                    await viewModel.fetchAllRecords()
                    proxy.scrollTo(chartViewID, anchor: .trailing) // 右端へスクロール
                }
            }
            
            CommonLoadingView()
                .hidden(!viewModel.isLoading)
        }
    }
}
