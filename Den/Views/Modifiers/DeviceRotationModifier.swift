//
//  DeviceRotationModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DeviceRotationModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
