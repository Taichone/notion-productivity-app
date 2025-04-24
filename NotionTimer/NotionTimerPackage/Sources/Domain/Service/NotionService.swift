import Foundation
import Observation
import DataLayer

// TODO: NotionAuthService を作り認証周りを抜き出すことを検討
public actor NotionService {
    private let keychainClient: KeychainClient
    private let notionClient: NotionAPIClient
    private let notionAuthClient: NotionAuthClient
    
    private var accessToken: String? {
        get async {
            keychainClient.retrieveToken(.notionAccessToken)
        }
    }
    private var databaseID: String? {
        get async {
            keychainClient.retrieveToken(.notionDatabaseID)
        }
    }
    
    private var _authStatus: NotionAuthStatus = .loading
    public var authStatus: NotionAuthStatus {
        get { _authStatus }
        set { _authStatus = newValue }
    }
    
    public init(
        keychainClient: KeychainClient,
        notionClient: NotionAPIClient,
        notionAuthClient: NotionAuthClient
    ) {
        self.keychainClient = keychainClient
        self.notionClient = notionClient
        self.notionAuthClient = notionAuthClient
    }
    
    public func fetchAccessToken(temporaryToken: String) async throws {
        _authStatus = .loading
        
        do {
            let accessToken = try await notionAuthClient.getAccessToken(temporaryToken)
            
            guard keychainClient.saveToken(accessToken, .notionAccessToken) else {
                throw NotionServiceError.failedToSaveToKeychain
            }
            
            await fetchAuthStatus()
        } catch {
            _authStatus = .invalidToken
            throw error
        }
    }
    
    public func fetchAuthStatus() async {
        guard await accessToken != nil else {
            _authStatus = .invalidToken
            return
        }
        
        guard await databaseID != nil else {
            _authStatus = .invalidDatabase
            return
        }
        
        // TODO: token, databaseID の有効チェック
        _authStatus = .complete
    }
    
    public func releaseAccessToken() async {
        guard keychainClient.deleteToken(.notionAccessToken),
              keychainClient.deleteToken(.notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        _authStatus = .invalidToken
    }
    
    public func releaseSelectedDatabase() async {
        guard keychainClient.deleteToken(.notionDatabaseID) else {
            fatalError("Keychain からトークンを削除できない")
        }
        
        _authStatus = .invalidDatabase
    }
}

extension NotionService {
    private func token() async throws -> String {
        guard let token = await accessToken else {
            throw NotionServiceError.failedToRetrieveTokenFromKeychain
        }
        return token
    }
    
    public func getPageList() async throws -> [NotionPage] {
        guard let token = await accessToken else {
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
        _authStatus = .complete
    }
    
    public func record(time: Int, tags: [NotionTag], description: String) async throws {
        guard let databaseID = await databaseID else {
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
        guard let databaseID = await databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getDatabaseTags(
            await token(),
            databaseID
        )
    }
    
    public func getAllRecords() async throws -> [Record] {
        guard let databaseID = await databaseID else {
            throw NotionServiceError.invalidDatabase
        }
        
        return try await notionClient.getAllRecords(
            await token(),
            databaseID
        )
    }
}
