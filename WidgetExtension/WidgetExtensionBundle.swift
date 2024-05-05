//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Garrett Johnson on 4/28/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        LatestItemsWidget()
    }
}
