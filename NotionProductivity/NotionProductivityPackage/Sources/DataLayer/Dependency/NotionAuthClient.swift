import Foundation
import Alamofire

public struct NotionAuthClient: DependencyClient {
    public var fetchAccessToken: @Sendable (String) async throws -> String
    
    public static let liveValue = Self(
        fetchAccessToken: fetchAccessToken
    )
    
    public static let testValue = Self(
        fetchAccessToken: { _ in "" }
    )
}

extension NotionAuthClient {
    private struct FetchAccessTokenRequestBody: Encodable {
        let code: String
    }
    
    private struct FetchAccessTokenResponseBody: Decodable {
        let accessToken: String
    }
    
    /// temporaryToken から accessToken を取得
    private static func fetchAccessToken(temporaryToken: String) async throws -> String {
        let endPoint = Self.notionTokenExchangeURL
        let headers: HTTPHeaders = ["Content-Type": "application/json"]
        let requestBody = FetchAccessTokenRequestBody(code: temporaryToken)
        
        do {
            let response = try await AF.request(
                endPoint,
                method: .post,
                parameters: requestBody,
                encoder: JSONParameterEncoder(encoder: JSONEncoder.snakeCase),
                headers: headers
            )
                .validate()
                .serializingDecodable(FetchAccessTokenResponseBody.self, decoder: JSONDecoder.snakeCase).value
            
            return response.accessToken
        } catch {
            debugPrint(error)
            throw NotionServiceError.failedToFetchAccessToken
        }
    }
    
    private static let notionTokenExchangeURL: URL = URL(
        string: Bundle.main.object(forInfoDictionaryKey: "NOTION_TOKEN_EXCHANGE_URL") as! String
    )!
}
