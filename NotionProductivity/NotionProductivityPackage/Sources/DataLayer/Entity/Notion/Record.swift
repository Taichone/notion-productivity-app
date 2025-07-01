import Foundation

public struct Record: Identifiable, Hashable, Sendable {
    public let id: String
    public let date: Date
    public let description: String
    public let tags: [NotionTag]
    public let time: Int
}
