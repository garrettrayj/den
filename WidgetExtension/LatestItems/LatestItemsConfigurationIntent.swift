//
//  LatestItemsConfigurationIntent.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import WidgetKit
import AppIntents

struct LatestItemsConfigurationIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configuration"

    @Parameter(title: "Source")
    var source: SourceDetail?

    init(source: SourceDetail) {
        self.source = source
    }

    init() {
    }
}
