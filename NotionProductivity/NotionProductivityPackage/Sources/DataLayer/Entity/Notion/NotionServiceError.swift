public enum NotionServiceError: Error {
    case failedToSaveToKeychain
    case failedToReadAccessTokenFromKeychain
    case failedToReadDatabaseIDFromKeychain
    case failedToFetchAccessToken
    case failedToDeleteAccessTokenFromKeychain
    case failedToDeleteDatabaseIDFromKeychain
    case accessTokenNotFound
    case invalidClient
    case invalidDatabase
    case parentPageIsNotSelected
    case failedToGetPageList(error: Error)
    case failedToGetRecordList(error: Error)
    case failedToGetDatabaseList(error: Error)
    case failedToCreateDatabase(error: Error)
}
