//
//  FeedWidgetViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class FeedWidgetViewModel: ObservableObject {
    @Published var feed: Feed

    var pageViewModel: PageViewModel

    init(feed: Feed, pageViewModel: PageViewModel) {
        self.feed = feed
        self.pageViewModel = pageViewModel
    }
}
