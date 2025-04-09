//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import DataLayer
import Domain

public struct RootView: View {
    private let screenTimeClient: ScreenTimeClient
    private let notionService: NotionService
    
    @State private var viewModel: RootViewModel
    
    public init(notionService: NotionService, screenTimeClient: ScreenTimeClient) {
        self.screenTimeClient = screenTimeClient
        self.notionService = notionService
        self.viewModel = .init(notionService: notionService)
    }
    
    public var body: some View {
        NavigationStack {
            switch viewModel.authStatus {
            case .loading:
                CommonLoadingView()
            case .invalidToken:
                LoginView()
            case .invalidDatabase:
                DatabaseSelectionView(notionService: notionService)
            case .complete:
                HomeView(
                    notionService: notionService,
                    screenTimeClient: screenTimeClient
                )
            }
        }
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .onOpenURL(perform: { url in
            Task {
                await viewModel.onOpenURL(url)
            }
        })
        .animation(.default, value: viewModel.authStatus)
    }
}

#Preview {
    RootView(
        notionService: .init(
            keychainClient: .testValue,
            notionClient: .testValue,
            notionAuthClient: .testValue),
        screenTimeClient: .testValue
    )
}
