//
//  SidebarPageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 2/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation

class SdfsPageSidebarItemViewModel: ObservableObject {
    private var queuedSubscriber: AnyCancellable?
    private var refreshedSubscriber: AnyCancellable?

    var page: Page
    @Published var refreshing: Bool

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
