//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class PageViewModel: ObservableObject {
    enum PageViewMode {
        case wires
    }
    
    @Published var page: Page
    @Published var pageViewMode: PageViewMode = .wires
    @Published var pageSheetViewModel: PageSheetViewModel?
    @Published var showingMenu: Bool = false
    
    init(page: Page) {
        self.page = page
    }
    
    func hasFeeds() -> Bool {
        return self.page.feedsArray.count > 0
    }
}
