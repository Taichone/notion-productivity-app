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
    @Environment(\.appServices) private var appServices
    @State private var authStatus: NotionAuthStatus = .loading
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            switch authStatus {
            case .loading:
                CommonLoadingView()
            case .invalidToken:
                LoginView()
            case .invalidDatabase:
                DatabaseSelectionView(notionService: appServices.notionService)
            case .complete:
                HomeView()
            }
        }
        .onAppear {
            Task {
                await appServices.notionService.fetchAuthStatus()
                authStatus = await appServices.notionService.authStatus
            }
        }
        .onOpenURL(perform: { url in
            if let deeplink = url.getDeeplink() {
                switch deeplink {
                case .notionTemporaryToken(let token):
                    Task {
                        do {
                            try await appServices.notionService.fetchAccessToken(temporaryToken: token)
                            await appServices.notionService.fetchAuthStatus()
                            authStatus = await appServices.notionService.authStatus
                        } catch {
                            // TODO: アラートを表示（アクセストークンの取得に失敗）
                            debugPrint(error)
                        }
                    }
                }
            }
        })
        .animation(.default, value: authStatus)
    }
}

#Preview {
    RootView()
}
