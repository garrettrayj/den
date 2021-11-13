//
//  PageSettingsViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class PageSettingsViewModel: ObservableObject {
    @Published var page: Page
    @Published var itemsPerFeedStepperValue: Int = 0
    @Published var showingIconPicker: Bool = false

    init(page: Page) {
        self.page = page
    }
}
