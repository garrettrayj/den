//
//  FeedViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation

final class FeedViewModel: ObservableObject {
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

extension FeedViewModel: Identifiable {
    var id: Feed {
        feed
    }
}

extension FeedViewModel: Equatable {
    static func == (lhs: FeedViewModel, rhs: FeedViewModel) -> Bool {
        lhs.feed == rhs.feed
    }
}

extension FeedViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(feed)
    }
}
