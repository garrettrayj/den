//
//  CGSize+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

extension CGSize {
    func scaled(by scalingFactor: Double) -> CGSize {
        CGSize(width: self.width * scalingFactor, height: self.height * scalingFactor)
    }
}
