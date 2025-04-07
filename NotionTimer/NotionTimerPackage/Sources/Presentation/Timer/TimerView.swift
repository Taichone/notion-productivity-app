//
//  TimerView.swift
//  NotionTimer
//
//  Created by Taichi on 2024/08/13.
//

import SwiftUI
import DataLayer
import Domain

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appServices) private var appServices
    @Environment(\.appRouter) private var appRouter
    @State private var viewModel: TimerViewModel
    
    private let focusColor: Color
    private let breakColor: Color
    
    init(dependency: AppRouter.TimerDependency) {
        self.focusColor = dependency.focusColor
        self.breakColor = dependency.breakColor
        self.viewModel = .init(
            isManualBreakStartEnabled: dependency.isManualBreakStartEnabled,
            focusTimeSec: dependency.focusTimeSec,
            breakTimeSec: dependency.breakTimeSec,
            screenTimeClient: ScreenTimeClient.liveValue
        )
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(viewModel.timerModeName)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "remaining-time"))
                    Spacer()
                    Text(viewModel.remainingTimeString)
                }
                
                Divider()
                
                HStack {
                    Text(String(moduleLocalized: "total-focus-time"))
                    Spacer()
                    Text(viewModel.totalFocusTimeString)
                }
            }
            .padding()
            .background {
                GlassmorphismRoundedRectangle()
            }
            
            Spacer()
            
            ZStack {
                TimerCircle(color: Color(.secondarySystemBackground))
                TimerCircle(
                    color: viewModel.modeColor,
                    trimFrom: viewModel.trimFrom,
                    trimTo: viewModel.trimTo
                )
                .animation(.smooth, value: viewModel.trimFrom)
                .animation(.smooth, value: viewModel.trimTo)
                .rotationEffect(Angle(degrees: -90))
                .shadow(radius: 10)
            }
            
            Spacer()
            
            Button {
                ExternalOutput.tapticFeedback()
                viewModel.tapBreakStartButton()
            } label: {
                Text(String(moduleLocalized: "start-break")).bold()
            }
            .hidden(viewModel.startBreakButtonDisabled)
            
            Button {
                ExternalOutput.tapticFeedback()
                viewModel.tapPlayButton()
            } label: {
                Image(systemName: viewModel.timerButtonSystemName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationTitle(String(moduleLocalized: "timer"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 確認アラートを挟む
                    viewModel.terminate()
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(String(moduleLocalized: "cancel"))
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 確認アラートを挟む
                    appRouter.items.append(.timerRecord(dependency: .init(
                        resultFocusTimeSec: viewModel.totalFocusTimeSec
                    )))
                    viewModel.terminate()
                    
                } label: {
                    Text(String(moduleLocalized: "done"))
                }
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    NavigationStack {
        TimerView(dependency: AppRouter.TimerDependency(
            isBreakEndSoundEnabled: true,
            isManualBreakStartEnabled: true,
            focusTimeSec: 1500,
            breakTimeSec: 300,
            focusColor: .mint,
            breakColor: .pink
        ))
    }
}
