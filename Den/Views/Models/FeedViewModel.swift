//
//  FeedViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class FeedViewModel: ObservableObject {
    @Published var feed: Feed
    @Published var showingSettings: Bool = false
    @Published var refreshing: Bool = false

    init(feed: Feed) {
        self.feed = feed
    }
}
