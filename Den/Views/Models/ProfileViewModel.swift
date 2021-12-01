//
//  ProfileViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile
    @Published var refreshing: Bool = false

    var queuedSubscriber: AnyCancellable?
    var refreshedSubscriber: AnyCancellable?

    init(profile: Profile) {
        self.profile = profile

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
