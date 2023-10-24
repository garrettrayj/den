//
//  CGSize+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

extension CGSize {
    var area: CGFloat {
        width * height
    }

    func scaled(by scalingFactor: Double) -> CGSize {
        CGSize(width: self.width * scalingFactor, height: self.height * scalingFactor)
    }
}
