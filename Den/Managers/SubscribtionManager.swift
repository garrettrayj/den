//
//  SubscribeManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class SubscriptionManager: ObservableObject {
    @Published public var showSubscribeView: Bool = false
    @Published public var currentPage: Page? // Current page updated by PageView onAppear()
    @Published public var feedURLString: String = ""
    
    init() {
    }
    
    public func subscribe(to url: URL? = nil) {
        if let url = url {
            feedURLString = url.absoluteString.replacingOccurrences(of: "feed:", with: "")
        }
        showSubscribeView = true
    }
    
    public func reset() {
        showSubscribeView = false
        feedURLString = ""
    }
}
