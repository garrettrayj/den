//
//  FeedViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class FeedViewModel: ObservableObject {
    @Published var feed: Feed
    @Published var refreshing = false

    init(feed: Feed) {
        self.feed = feed
    }
}
