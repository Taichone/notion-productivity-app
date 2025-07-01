@preconcurrency import NotionSwift

public enum NotionServiceError: Error {
    case keychainError(KeychainError)
    case failedToFetchAccessToken
    case clientError(NotionErrorCode)
    case invalidDatabaseFormat
    case logicalError
}

extension NotionServiceError {
    public enum KeychainError: Error {
        case failedToSaveToKeychain
        case failedToReadAccessTokenFromKeychain
        case failedToReadDatabaseIDFromKeychain
        case failedToDeleteAccessTokenFromKeychain
        case failedToDeleteDatabaseIDFromKeychain
    }
}
