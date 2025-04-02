//
//  URL+Deeplink.swift
//  NotionTimerPackage
//
//  Created by Taichi on 2024/11/02.
//

import Foundation

extension URL {
    enum Deeplink {
        case notionTemporaryToken(token: String)
    }
    
    func getDeeplink() -> Deeplink? {
        guard scheme == "notion-timer",
              let host = host,
              let queryUrlComponents = URLComponents(string: absoluteString) else {
            return nil
        }
        
        switch host {
        case "oauth":
            if let notionTemporaryToken = queryUrlComponents.getParameterValue(for: "code") {
                return Deeplink.notionTemporaryToken(token: notionTemporaryToken)
            }
        default:
            break
        }
        return nil
    }

}

extension URLComponents {
    func getParameterValue(for parameter: String) -> String? {
        queryItems?.first(where: { $0.name == parameter })?.value
    }
}
