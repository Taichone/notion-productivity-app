//
//  nini.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/02.
//

public enum NotionServiceError: Error {
    case failedToSaveToKeychain
    case failedToRetrieveTokenFromKeychain
    case failedToFetchAccessToken
    case accessTokenNotFound
    case invalidClient
    case invalidDatabase
    case failedToGetPageList(error: Error)
    case failedToGetRecordList(error: Error)
    case failedToGetDatabaseList(error: Error)
    case failedToCreateDatabase(error: Error)
}
