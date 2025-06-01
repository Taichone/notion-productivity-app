import Foundation
import Observation
import DataLayer

// TODO: NotionAuthService を作り認証周りを抜き出すことを検討
public actor NotionService {
    private let keychainClient: KeychainClient
    private let notionClient: NotionAPIClient
    private let notionAuthClient: NotionAuthClient
    
    // State
    public var authStatus: NotionAuthStatus = .invalidToken
    
    public init(
        keychainClient: KeychainClient,
        notionClient: NotionAPIClient,
        notionAuthClient: NotionAuthClient
    ) {
        self.keychainClient = keychainClient
        self.notionClient = notionClient
        self.notionAuthClient = notionAuthClient
    }
    
    private func accessToken() async -> String? {
        keychainClient.retrieveToken(.notionAccessToken)
    }
    
    private func databaseID() async -> String? {
        keychainClient.retrieveToken(.notionDatabaseID)
    }
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        do {
            let accessToken = try await notionAuthClient.fetchAccessToken(temporaryToken)
            guard keychainClient.saveToken(accessToken, .notionAccessToken) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            await updateAuthStatus()
        } catch {
            await updateAuthStatus()
            throw error
        }
    }
    
    public func updateAuthStatus() async {
        guard let _ = await accessToken() else {
            authStatus = .invalidToken
            return
        }
        
        guard let _ = await databaseID() else {
            authStatus = .invalidDatabase
            return
        }
        
        // TODO: token, databaseID の有効チェック
        authStatus = .complete
    }
    
    public func releaseAccessToken() async throws {
        guard keychainClient.deleteToken(.notionAccessToken) else {
            throw NotionServiceError.failedToDeleteAccessTokenFromKeychain
        }
        await updateAuthStatus()
    }
    
    public func releaseAccessTokenAndDatabase() async throws {
        guard keychainClient.deleteToken(.notionAccessToken),
              keychainClient.deleteToken(.notionDatabaseID) else {
            throw NotionServiceError.failedToDeleteAccessTokenFromKeychain
        }
        await updateAuthStatus()
    }
    
    public func releaseDatabase() async throws {
        guard keychainClient.deleteToken(.notionDatabaseID) else {
            throw NotionServiceError.failedToDeleteDatabaseIDFromKeychain
        }
        await updateAuthStatus()
    }
}

extension NotionService {
    private func token() async throws -> String {
        guard let token = await accessToken() else {
            throw NotionServiceError.failedToReadAccessTokenFromKeychain
        }
        return token
    }
    
    public func getPageList() async throws -> [NotionPage] {
        guard let token = await accessToken() else {
            throw NotionServiceError.invalidClient
        }
        
        do {
            return try await notionClient.getPageList(token)
        } catch {
            throw NotionServiceError.failedToGetPageList(error: error)
        }
    }
        
    public func getCompatibleDatabaseList() async throws -> [NotionDatabase] {
        do {
            return try await notionClient.getCompatibleDatabaseList(await token())
        } catch {
            throw NotionServiceError.failedToGetDatabaseList(error: error)
        }
    }
    
    public func createDatabase(parentPageID: String, title: String) async throws {
        do {
            let databaseID = try await notionClient.createDatabaseAndGetDatabaseID(
                await token(),
                parentPageID,
                title
            )
            
            try await registerDatabase(id: databaseID)
        } catch {
            throw NotionServiceError.failedToCreateDatabase(error: error)
        }
    }
    
    public func registerDatabase(id: String) async throws {
        guard keychainClient.saveToken(id, .notionDatabaseID) else {
            throw NotionServiceError.failedToSaveToKeychain
        }
    }
    
    public func record(time: Int, tags: [NotionTag], description: String) async throws {
        guard let databaseID = await databaseID() else {
            throw NotionServiceError.invalidDatabase
        }
        
        try await notionClient.record(
            await token(),
            Date(),
            time,
            tags,
            description,
            databaseID
        )
    }
    
    public func getDatabaseTags() async throws -> [NotionTag] {
        guard let databaseID = await databaseID() else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getDatabaseTags(
            await token(),
            databaseID
        )
    }
    
    public func getAllRecords() async throws -> [Record] {
        guard let databaseID = await databaseID() else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getAllRecords(
            await token(),
            databaseID
        )
    }
}
