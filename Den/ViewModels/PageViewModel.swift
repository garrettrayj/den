//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation

class PageViewModel: ObservableObject {
    @Published var page: Page
    @Published var refreshing: Bool

    var queuedSubscriber: AnyCancellable?
    var refreshedSubscriber: AnyCancellable?

    init(page: Page, refreshing: Bool) {
        self.page = page
        self.refreshing = refreshing

        self.queuedSubscriber = NotificationCenter.default
            .publisher(for: .pageQueued, object: page.objectID)
            .receive(on: RunLoop.main)
            .map { _ in true }
            .assign(to: \.refreshing, on: self)

        self.refreshedSubscriber = NotificationCenter.default
            .publisher(for: .pageRefreshed, object: page.objectID)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: \.refreshing, on: self)
    }

    deinit {
        queuedSubscriber?.cancel()
        refreshedSubscriber?.cancel()
    }
}

extension PageViewModel: Identifiable {
    static func == (lhs: PageViewModel, rhs: PageViewModel) -> Bool {
        lhs.page == rhs.page
    }
}

extension PageViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(page)
    }
}
