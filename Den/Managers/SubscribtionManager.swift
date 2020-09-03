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
    
    public func subscribe(to url: URL? = nil) {
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }
            
            if let urlString = urlComponents.string {
                feedURLString = urlString
                return
            }
        }
        
        showSubscribeView = true
    }
    
    public func reset() {
        showSubscribeView = false
        feedURLString = ""
    }
}
