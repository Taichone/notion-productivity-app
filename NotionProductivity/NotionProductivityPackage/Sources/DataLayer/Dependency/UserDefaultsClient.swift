import Foundation

public struct UserDefaultsClient: DependencyClient {
    public let userDefaults = UserDefaults.standard
    var bool: @Sendable (String) -> Bool
    var setBool: @Sendable (Bool, String) -> Void
    var string: @Sendable (String) -> String
    var setString: @Sendable (String, String) -> Void
    var int: @Sendable (String) -> Int
    var setInt: @Sendable (Int, String) -> Void
    var data: @Sendable (String) -> Data?
    var setData: @Sendable (Data?, String) -> Void
    
    public func registerDefaults(_ defaults: [String: Any]) {
        userDefaults.register(defaults: defaults)
    }

    public static let liveValue = Self(
        bool: { UserDefaults.standard.bool(forKey: $0) },
        setBool: { UserDefaults.standard.set($0, forKey: $1) },
        string: { UserDefaults.standard.string(forKey: $0) ?? "" },
        setString: { UserDefaults.standard.set($0, forKey: $1) },
        int: { UserDefaults.standard.integer(forKey: $0) },
        setInt: { UserDefaults.standard.set($0, forKey: $1) },
        data: { UserDefaults.standard.data(forKey: $0) },
        setData: { UserDefaults.standard.set($0, forKey: $1) }
    )

    public static let testValue = Self(
        bool: { _ in false },
        setBool: { _, _ in },
        string: { _ in "" },
        setString: { _, _ in },
        int: { _ in 0 },
        setInt: { _, _ in },
        data: { _ in nil },
        setData: { _, _ in }
    )
}

extension UserDefaults: @retroactive @unchecked Sendable {}
