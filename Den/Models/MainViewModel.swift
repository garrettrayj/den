//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class MainViewModel: ObservableObject {
    enum PageSheetMode {
        case none, organizer, options, subscribe
    }
    
    @Published var activePage: Page?
    @Published var pageSheetMode: PageSheetMode = .none
    @Published var pageSheetSubscription: Subscription?
    @Published var showingPageSheet: Bool = false
}
