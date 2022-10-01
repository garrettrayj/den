//
//  HapticImpactModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HapticImpactModifier: ViewModifier {
    @EnvironmentObject private var haptics: Haptics

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        haptics.tapFeedbackGenerator?.impactOccurred()
                    }
            )
    }
}
