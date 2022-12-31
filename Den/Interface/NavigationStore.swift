//
//  NavigationStore.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

protocol URLHandler {
    func handle(_ url: URL, mutating: inout NavigationPath)
}

protocol ActivityHandler {
    func handle(_ activity: NSUserActivity, mutating: inout NavigationPath)
}

class DefaultURLHandler: URLHandler {
    func handle(_ url: URL, mutating: inout NavigationPath) {
        
    }
}

class DefaultActivityHandler: ActivityHandler {
    func handle(_ activity: NSUserActivity, mutating: inout NavigationPath) {
        
    }
}


@MainActor final class NavigationStore: ObservableObject {
    @Published var path = NavigationPath()
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let urlHandler: URLHandler
    private let activityHandler: ActivityHandler
    
    init(urlHandler: URLHandler, activityHandler: ActivityHandler) {
        self.urlHandler = urlHandler
        self.activityHandler = activityHandler
    }
    
    func handle(_ activity: NSUserActivity) {
        activityHandler.handle(activity, mutating: &path)
    }
    
    func handle(_ url: URL) {
        urlHandler.handle(url, mutating: &path)
    }
    
    func encoded() -> Data? {
        try? path.codable.map(encoder.encode)
    }
    
    func restore(from data: Data) {
        do {
            let codable = try decoder.decode(
                NavigationPath.CodableRepresentation.self, from: data
            )
            path = NavigationPath(codable)
        } catch {
            path = NavigationPath()
        }
    }
}
