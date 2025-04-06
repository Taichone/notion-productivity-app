//
//  SettingViewModel.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/06.
//

import DataLayer
import SwiftUI
import Observation

@MainActor @Observable public final class SettingViewModel {
    private let notionService: NotionService
    
    public init(notionService: NotionService) {
        self.notionService = notionService
    }
    
    public func reselectDatabase() async {
        await notionService.releaseSelectedDatabase()
    }
    
    public func logout() async {
        await notionService.releaseAccessToken()
    }
}

