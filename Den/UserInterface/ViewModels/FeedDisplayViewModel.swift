//
//  FeedDisplayViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

final class FeedDisplayViewModel: ObservableObject {
    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    @Published var feed: Feed
    @Published var refreshing: Bool

    init(feed: Feed, refreshing: Bool) {
        self.feed = feed
        self.refreshing = refreshing

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .feedQueued, object: feed.objectID)
            .receive(on: RunLoop.main)
            .map { _ in true }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .feedRefreshed, object: feed.objectID)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: \.refreshing, on: self)
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
    }
}

extension FeedDisplayViewModel: Identifiable {
    var id: Feed {
        feed
    }
}

extension FeedDisplayViewModel: Equatable {
    static func == (lhs: FeedDisplayViewModel, rhs: FeedDisplayViewModel) -> Bool {
        lhs.feed == rhs.feed
    }
}

extension FeedDisplayViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(feed)
    }
}
