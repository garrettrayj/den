//
//  ScreenManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class ScreenManager: ObservableObject {
    @Published var activeScreen: String? = nil
    @Published var currentPage: Page? // Current page updated by PageView onAppear()
    @Published var showSubscribe: Bool = false
    @Published var subscribeURLString: String = ""
    
    func subscribe(to url: URL? = nil) {        
        if
            let url = url,
            var urlComponents = URLComponents(string: url.absoluteString.replacingOccurrences(of: "feed:", with: ""))
        {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }
            
            if let urlString = urlComponents.string {
                subscribeURLString = urlString
            }
        }
        
        self.showSubscribe = true
    }
    
    func resetSubscribe() {
        showSubscribe = false
        subscribeURLString = ""
    }
}
