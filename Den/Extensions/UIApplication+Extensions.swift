//
//  UIApplication+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/24.
//  Copyright © 2024 
//
//  SPDX-License-Identifier: MIT
//

#if !os(macOS)
import UIKit

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow
    }
}
#endif
