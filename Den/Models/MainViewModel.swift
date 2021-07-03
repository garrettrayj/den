//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    enum PageSheetMode {
        case none, feedPreferences, subscribe, crashMessage
    }
    
    @Published var activeProfile: Profile?
    @Published var activePage: Page?
    @Published var pageSheetMode: PageSheetMode = .none
    @Published var pageSheetFeed: Feed?
    @Published var showingPageSheet: Bool = false
}
