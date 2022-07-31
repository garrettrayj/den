//
//  TimelineViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import CoreData
import SwiftUI

class TimelineViewModel: ObservableObject {
    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    private var itemReadSubscriber: AnyCancellable?
    private var itemUnreadSubscriber: AnyCancellable?

    @Published var profile: Profile
    @Published var refreshing: Bool
    @Published var unread: Int

    init(profile: Profile, refreshing: Bool) {
        self.profile = profile
        self.refreshing = refreshing
        self.unread = profile.previewItems.unread().count

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .profileQueued, object: profile.objectID)
            .receive(on: RunLoop.main)
            .map { _ in true }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .profileRefreshed, object: profile.objectID)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: \.refreshing, on: self)

        self.itemReadSubscriber = NotificationCenter.default
            .publisher(for: .itemRead)
            .receive(on: RunLoop.main)
            .sink { _ in
                self.unread -= 1
            }

        self.itemUnreadSubscriber = NotificationCenter.default
            .publisher(for: .itemUnread)
            .receive(on: RunLoop.main)
            .sink { _ in
                self.unread += 1
            }
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
        itemReadSubscriber?.cancel()
        itemUnreadSubscriber?.cancel()
    }
}
