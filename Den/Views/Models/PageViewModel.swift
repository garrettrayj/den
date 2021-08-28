//
//  PageViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class PageViewModel: ObservableObject {
    @Published var page: Page
    @Published var refreshing: Bool = false
    @Published var showingSettings: Bool = false
    @Published var refreshFractionCompleted: CGFloat = 0

    let progress = Progress(totalUnitCount: 0)

    init(page: Page) {
        self.page = page

        progress
            .publisher(for: \.fractionCompleted)
            .receive(on: RunLoop.main)
            .map { fractionCompleted in
                return CGFloat(fractionCompleted)
            }
            .assign(to: &$refreshFractionCompleted)
    }
}
