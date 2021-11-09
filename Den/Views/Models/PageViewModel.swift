//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class PageViewModel: ObservableObject, Identifiable {
    @Published var page: Page
    @Published var refreshing: Bool = false
    @Published var refreshFractionCompleted: CGFloat = 0
    @Published var progress = Progress(totalUnitCount: 0)

    @Published var showingSettings: Bool = false
    @Published var itemsPerFeedStepperValue: Int = 0
    @Published var showingIconPicker: Bool = false
    @Published var refreshAfterSave: Bool = false

    var contentViewModel: ContentViewModel

    init(page: Page, contentViewModel: ContentViewModel) {
        self.page = page
        self.contentViewModel = contentViewModel

        progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .map { fractionCompleted in
                CGFloat(fractionCompleted)
            }
            .assign(to: &$refreshFractionCompleted)
    }

    func refresh() {
        contentViewModel.refresh(pageViewModel: self)
    }
}
