//
//  ScreenManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

final class SubscriptionManager: ObservableObject {
    @Published var showSubscribe: Bool = false
    @Published var subscribeURLString: String = ""
    
    var mainViewModel: MainViewModel
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
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
        
        self.mainViewModel.pageSheetMode = .subscribe
        self.mainViewModel.showingPageSheet = true
    }
    
    func reset() {
        showSubscribe = false
        subscribeURLString = ""
    }
}
