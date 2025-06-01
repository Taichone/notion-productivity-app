import Foundation

public struct NotionDatabase: Sendable, Hashable, Identifiable {
    public let id: String
    public let title: String
    
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}
