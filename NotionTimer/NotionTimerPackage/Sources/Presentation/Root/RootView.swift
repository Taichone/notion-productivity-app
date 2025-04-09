//
//  RootView.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/10/20.
//

import SwiftUI
import DataLayer
import Domain

@MainActor @Observable public final class RootViewModel {
    private let notionService: NotionService
    public var authStatus: NotionAuthStatus
    
    public init(notionService: NotionService) {
        self.authStatus = .loading
        self.notionService = notionService
    }
    
    public func onAppear() async {
        await notionService.fetchAuthStatus()
        authStatus = await notionService.authStatus
    }
    
    public func onOpenURL(_ url: URL) async {
        if let deeplink = url.getDeeplink() {
            switch deeplink {
            case .notionTemporaryToken(let token):
                Task {
                    do {
                        try await notionService.fetchAccessToken(temporaryToken: token)
                        await notionService.fetchAuthStatus()
                        authStatus = await notionService.authStatus
                    } catch {
                        // TODO: アラートを表示（アクセストークンの取得に失敗）
                        debugPrint(error)
                    }
                }
            }
        }
    }
}


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
