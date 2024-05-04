//
//  LatestItemsConfigurationIntent.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WidgetKit
import AppIntents

struct LatestItemsConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Shows latest items.")

    @Parameter(title: "Source")
    var source: SourceDetail

    init(source: SourceDetail) {
        self.source = source
    }

    init() {
    }
}
