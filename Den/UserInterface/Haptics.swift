//
//  Haptics.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

class Haptics: ObservableObject {
    var lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    var mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var notificationFeedbackGenerator = UINotificationFeedbackGenerator()
}
