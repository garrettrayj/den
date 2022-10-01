//
//  Haptics.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

class Haptics: ObservableObject {
    var tapFeedbackGenerator: UIImpactFeedbackGenerator?
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator?

    func setup(enabled: Bool, tapStyle: HapticsMode) {
        if !enabled {
            tapFeedbackGenerator = nil
            notificationFeedbackGenerator = nil
            return
        }

        notificationFeedbackGenerator = UINotificationFeedbackGenerator()

        switch tapStyle {
        case .off:
            tapFeedbackGenerator = nil
        case .light:
            tapFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        case .medium:
            tapFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy:
            tapFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        }
    }
}
