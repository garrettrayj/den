//
//  Haptics.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Haptics {
    static let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    static let mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    static let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
}
