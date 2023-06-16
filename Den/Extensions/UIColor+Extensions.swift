//
//  UIColor+Extensions.swift
//  Den
//
//  Created by Anonymous S.I. on 04/03/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

extension Color {
    var hexString: String {
        let components = self.cgColor?.components
        let red = components?[safe: 0] ?? 0.0
        let green = components?[safe: 1] ?? 0.0
        let blue = components?[safe: 2] ?? 0.0

        let hexString = String.init(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255))
        )

        return hexString
    }
}
