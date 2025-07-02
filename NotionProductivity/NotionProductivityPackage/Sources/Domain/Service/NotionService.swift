import Foundation
import Observation
import DataLayer

// TODO: NotionAuthService を作り認証周りを抜き出すことを検討
public actor NotionService {
    private let keychainClient: KeychainClient
    private let notionClient: NotionAPIClient
    private let notionAuthClient: NotionAuthClient
    
    // MARK: States
    public var accessTokenStatus: NotionAccessTokenStatus = .notSelected
    public var timerRecordingDatabaseStatus: NotionDatabaseStatus = .notSelected
    
    public init(
        keychainClient: KeychainClient,
        notionClient: NotionAPIClient,
        notionAuthClient: NotionAuthClient
    ) {
        self.keychainClient = keychainClient
        self.notionClient = notionClient
        self.notionAuthClient = notionAuthClient
    }
    
    private func accessToken() throws -> String {
        guard let token = keychainClient.retrieveToken(.notionAccessToken) else {
            throw NotionServiceError.keychainError(.failedToReadAccessTokenFromKeychain)
        }
        return token
    }
    
    private func databaseID() throws -> String {
        guard let databaseID = keychainClient.retrieveToken(.notionDatabaseID) else {
            throw NotionServiceError.keychainError(.failedToReadDatabaseIDFromKeychain)
        }
        return databaseID
    }
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        do {
            let accessToken = try await notionAuthClient.fetchAccessToken(temporaryToken)
            guard keychainClient.saveToken(accessToken, .notionAccessToken) else {
                throw NotionServiceError.keychainError(.failedToSaveToKeychain)
            }
            await updateAccessTokenStatus()
        } catch {
            await updateAccessTokenStatus()
            throw error
        }
    }
    
    public func logout() async throws {
        guard keychainClient.deleteToken(.notionAccessToken) else {
            await updateAccessTokenStatus()
            throw NotionServiceError.keychainError(.failedToDeleteAccessTokenFromKeychain)
        }
        await updateAccessTokenStatus()
    }
        
    public func updateAccessTokenStatus() async {
        do {
            let _ = try accessToken()
            accessTokenStatus = .selected
        } catch {
            accessTokenStatus = .notSelected
        }
    }
    
    public func updateTimerRecordingDatabaseStatus() async {
        do {
            let _ = try databaseID()
            timerRecordingDatabaseStatus = .selected
        } catch {
            timerRecordingDatabaseStatus = .notSelected
        }
    }
    
    public func updateFastDatabaseStatus() async {
        do {
            let _ = try databaseID()
            fastDatabaseStatus = .selected
        } catch {
            fastDatabaseStatus = .notSelected
        }
    }
}

// MARK: NotionSwift 依存
extension NotionService {
    public func getPageList() async throws -> [NotionPage] {
        return try await notionClient.getPageList(accessToken())
    }
        
    public func getCompatibleDatabaseList() async throws -> [NotionDatabase] {
        return try await notionClient.getCompatibleDatabaseList(accessToken())
    }
    
    public func createDatabase(parentPageID: String, title: String) async throws -> NotionDatabase {
        let createdDatabase = try await notionClient.createDatabase(
            accessToken(),
            parentPageID,
            title
        )
        try await registerDatabase(id: createdDatabase.id)
        return createdDatabase
    }
    
    public func registerDatabase(id: String) async throws {
        guard keychainClient.saveToken(id, .notionDatabaseID) else {
            throw NotionServiceError.keychainError(.failedToSaveToKeychain)
        }
    }
    
    public func record(time: Int, tags: [NotionTag], description: String) async throws {
        try await notionClient.record(
            accessToken(),
            Date(),
            time,
            tags,
            description,
            databaseID()
        )
    }
    
    public func getDatabaseTags() async throws -> [NotionTag] {
        return try await notionClient.getDatabaseTags(
            accessToken(),
            databaseID()
        )
    }
    
    public func getFilteredRecords() async throws -> [Record] {
        return try await notionClient.getFilteredRecords(
            accessToken(),
            databaseID()
        )
    }
}
