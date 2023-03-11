//
//  ColorPalette.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

enum TintOption: String, CaseIterable {
    case red    = "Red"
    case orange = "Orange"
    case yellow = "Yellow"
    case green  = "Green"
    case mint   = "Mint"
    case teal   = "Teal"
    case cyan   = "Cyan"
    case blue   = "Blue"
    case indigo = "Indigo"
    case purple = "Purple"
    case pink   = "Pink"
    case brown  = "Brown"

    var uiColor: UIColor {
        switch self {
        case .red:
            return .systemRed
        case .orange:
            return .systemOrange
        case .yellow:
            return .systemYellow
        case .green:
            return .systemGreen
        case .mint:
            return .systemMint
        case .teal:
            return .systemTeal
        case .cyan:
            return .systemCyan
        case .blue:
            return .systemBlue
        case .indigo:
            return .systemIndigo
        case .purple:
            return .systemPurple
        case .pink:
            return .systemPink
        case .brown:
            return .systemBrown
        }
    }
    
    var color: Color {
        Color(self.uiColor)
    }
}
