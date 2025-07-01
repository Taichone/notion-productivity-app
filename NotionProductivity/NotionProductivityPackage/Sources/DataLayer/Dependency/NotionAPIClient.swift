import Foundation
@preconcurrency import NotionSwift

public struct NotionAPIClient: DependencyClient {
    public var getPageList: @Sendable (String) async throws -> [NotionPage]
    public var getCompatibleDatabaseList: @Sendable (String) async throws -> [NotionDatabase]
    public var createDatabase: @Sendable (String, String, String) async throws -> NotionDatabase
    public var record: @Sendable (String, Date, Int, [NotionTag], String, String) async throws -> Void
    public var getDatabaseTags: @Sendable (String, String) async throws -> [NotionTag]
    public var getFilteredRecords: @Sendable (String, String) async throws -> [Record]
    
    public static let liveValue = Self(
        getPageList: getPageList,
        getCompatibleDatabaseList: getCompatibleDatabaseList,
        createDatabase: createDatabase,
        record: record,
        getDatabaseTags: getDatabaseTags,
        getFilteredRecords: getFilteredRecords
    )
    
    public static let testValue = Self(
        getPageList: { _ in [] },
        getCompatibleDatabaseList: { _ in [] },
        createDatabase: { _, _, _ in .init(id: "", title: "") },
        record: { _, _, _, _, _, _ in },
        getDatabaseTags: { _, _ in [] },
        getFilteredRecords: { _, _ in [] }
    )
}

extension NotionAPIClient {
    private static func client(token: String) -> NotionClient {
        NotionClient(accessKeyProvider: StringAccessKeyProvider(accessKey: token))
    }
    
    public static func getFilteredRecords(
        token: String,
        databaseID: String
    ) async throws -> [Record] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).databaseQuery(databaseId: .init(databaseID)) {
                do {
                    var records = [Record]()
                    let pages = try $0.get()
                    pages.results.forEach { page in
                        if let record = page.asRecordEntity {
                            // 直近7日間のレコードのみを取得
                            if record.date > Date().addingTimeInterval(-7 * 24 * 60 * 60) {
                                records.append(record)
                            }
                        }
                    }
                    continuation.resume(returning: records)
                } catch {
                    continuation.resume(
                        throwing: error
                    )
                }
            }
        }
    }
    
    public static func record(
        token: String,
        date: Date,
        time: Int,
        tags: [NotionTag],
        description: String,
        databaseID: String
    ) async throws {
        let client = client(token: token)
        
        let multiSelectList: [PagePropertyType.MultiSelectPropertyValue] = tags.compactMap {
            .init(id: .init($0.id), name: nil, color: nil)
        }
        
        let request = PageCreateRequest(
            parent: .database(.init(databaseID)),
            properties: [
                "title": .init(
                    type: .title([
                        .init(string: "")
                    ])
                ),
                "Tag": .init(
                    type: .multiSelect(multiSelectList)
                ),
                "Time": .init(
                    type: .number(.init(time))
                ),
                "Description": .init(
                    type: .richText([
                        .init(string: description)
                    ])
                ),
                "Date": .init(
                    type: .date(.init(start: .dateAndTime(date), end: nil))
                )
            ]
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            client.pageCreate(request: request) { result in
                switch result {
                case .success:
                    continuation.resume(with: .success(()))
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public static func getDatabaseTags(
        token: String,
        databaseID: String
    ) async throws -> [NotionTag] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).database(databaseId: .init(databaseID)) { result in
                do {
                    let resultDatabase = try result.get()
                    guard let tagProperty = resultDatabase.properties["Tag"],
                          case .multiSelect(let selectOptions) = tagProperty.type
                    else {
                        throw NotionServiceError.invalidDatabaseFormat
                    }
                    
                    let tags: [NotionTag] = selectOptions.compactMap { selectOption in
                        guard let color = NotionTag.Color(rawValue: selectOption.color) else {
                            fatalError("ERROR: 無効な color 名のタグがある")
                        }
                        return .init(id: selectOption.id.rawValue, name: selectOption.name, color: color)
                    }
                    
                    continuation.resume(returning: tags)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public static func createDatabase(
        token: String,
        parentPageID: String,
        title: String
    ) async throws -> NotionDatabase {
        let request = DatabaseCreateRequest(
            parent: .pageId(.init(parentPageID)),
            icon: .none,
            cover: .none,
            title: [
                .init(string: title)
            ],
            properties: [
                "Date": .date,
                "Title": .title,
                "Tag": .multiSelect([]),
                "Time": .number(.numberWithCommas),
                "Description": .richText,
            ],
            isInline: true
        )

        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).databaseCreate(request: request) { result in
                switch result {
                case .success(let db):
                    if let dbEntity = db.asDatabaseEntity {
                        continuation.resume(returning: dbEntity)
                    } else {
                        continuation.resume(throwing: NotionServiceError.logicalError)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                    debugPrint(error.localizedDescription)
                }
            }
        }
    }
    
    public static func getCompatibleDatabaseList(token: String) async throws -> [NotionDatabase] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).search(request: .init(filter: .database)) { result in
                let resultDatabases = result.map { objects in
                    objects.results.compactMap({ object -> Database? in
                        if case .database(let db) = object {
                            let properties = db.properties
                            
                            // 記録に用いるプロパティをすべて持つ DB に絞る
                            if let dateProperty = properties["Date"],
                               case .date = dateProperty.type,
                               let tagProperty = properties["Tag"],
                               case .multiSelect = tagProperty.type,
                               let timeProperty = properties["Time"],
                               case .number = timeProperty.type,
                               let descriptionProperty = properties["Description"],
                               case .richText = descriptionProperty.type {
                                return db
                            }
                        }
                        return nil
                    })
                }
                
                do {
                    let databases = try resultDatabases.get().compactMap { $0.asDatabaseEntity }
                    continuation.resume(returning: databases)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    public static func getPageList(token: String) async throws -> [NotionPage] {
        return try await withCheckedThrowingContinuation { continuation in
            client(token: token).search(request: .init(filter: .page)) { result in
                let resultPages = result.map { objects in
                    objects.results.compactMap({ object -> Page? in
                        if case .page(let page) = object {
                            // TODO: DB 内の Page は除外したい
                            return page
                        }
                        return nil
                    })
                }
                
                do {
                    let pages = try resultPages.get().compactMap { $0.asPageEntity }
                    continuation.resume(returning: pages)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

extension Database {
    var asDatabaseEntity: NotionDatabase? {
        guard let title = title.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: id.rawValue, title: richTextType.content)
    }
}

extension Page {
    var asPageEntity: NotionPage? {
        guard let title = getTitle()?.first,
              case .text(let richTextType) = title.type else {
            return nil
        }
        return .init(id: id.rawValue, title: richTextType.content)
    }
    
    var asRecordEntity: Record? {
        guard case .richText(let richTexts) = properties["Description"]?.type,
              case .text(let textValue) = richTexts.first?.type,
              case .date(let dateRange) = properties["Date"]?.type,
              case .dateAndTime(let date) = dateRange?.start,
              case .multiSelect(let multiSelectValue) = properties["Tag"]?.type,
              case .number(let decimalTime) = properties["Time"]?.type,
              let decimalTime = decimalTime else {
            return nil
        }
        
        let description = textValue.content
        let time = NSDecimalNumber(decimal: decimalTime).intValue
        let tags: [NotionTag] = multiSelectValue.map {
            .init(
                id: $0.id?.rawValue ?? UUID().uuidString, // ForEach で表示するために補填
                name: $0.name ?? "",
                color: .init(rawValue: $0.color ?? "default") ?? .default
            )
        }
        
        return .init(
            id: id.rawValue,
            date: date,
            description: description,
            tags: tags,
            time: time
        )
    }
}
