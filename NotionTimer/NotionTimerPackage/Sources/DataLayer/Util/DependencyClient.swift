//
//  DependencyClientProtocol.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/02.
//

public protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}

public func testDependency<D: DependencyClient>(
    of type: D.Type,
    injection: (inout D) -> Void
) -> D {
    var dependencyClient = type.testValue
    injection(&dependencyClient)
    return dependencyClient
}
