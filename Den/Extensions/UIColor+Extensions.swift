//
//  UIColor+Extensions.swift
//  Den
//
//  Created by Anonymous S.I. on 04/03/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

extension UIColor {
    func adjust(brightness: CGFloat, saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alp: CGFloat = 0

        if getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alp) {
            bri += (brightness - 1.0)
            bri = max(min(bri, 1.0), 0.0)

            sat += (saturation - 1.0)
            sat = max(min(sat, 1.0), 0.0)

            return UIColor(hue: hue, saturation: sat, brightness: bri, alpha: alp)
        }

        return self
    }
}
