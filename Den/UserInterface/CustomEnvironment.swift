//
//  CustomEnvironment.swift
//  Den
//
//  Created by Garrett Johnson on 9/29/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

private struct HapticsModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: HapticsMode = .off
}

extension EnvironmentValues {
    var hapticsMode: HapticsMode {
        get { self[HapticsModeEnvironmentKey.self] }
        set { self[HapticsModeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func hapticsMode(_ hapticsMode: HapticsMode) -> some View {
        environment(\.hapticsMode, hapticsMode)
    }
}
