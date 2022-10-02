//
//  Haptics.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreHaptics

class Haptics: ObservableObject {
    var lightImpactFeedbackGenerator: UIImpactFeedbackGenerator?
    var mediumImpactFeedbackGenerator: UIImpactFeedbackGenerator?
    var notificationFeedbackGenerator: UINotificationFeedbackGenerator?

    func setup(enabled: Bool) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }

        guard enabled else {
            lightImpactFeedbackGenerator = nil
            mediumImpactFeedbackGenerator = nil
            notificationFeedbackGenerator = nil
            return
        }

        lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        mediumImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    }
}
