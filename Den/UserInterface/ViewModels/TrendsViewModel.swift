//
//  TrendsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import SwiftUI
import OSLog
import NaturalLanguage

class TrendsViewModel: ObservableObject {
    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    @Published var profile: Profile
    @Published var refreshing: Bool

    init(profile: Profile, refreshing: Bool) {
        self.profile = profile
        self.refreshing = refreshing

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
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
    }
}
