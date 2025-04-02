//
//  DependencyClientProtocol.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2025/04/02.
//

protocol DependencyClient: Sendable {
    static var liveValue: Self { get }
    static var testValue: Self { get }
}
