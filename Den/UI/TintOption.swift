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

    var labelText: Text {
        switch self {
        case .red:
            return Text("Red", comment: "Tint option")
        case .orange:
            return Text("Orange", comment: "Tint option")
        case .yellow:
            return Text("Yellow", comment: "Tint option")
        case .green:
            return Text("Green", comment: "Tint option")
        case .mint:
            return Text("Mint", comment: "Tint option")
        case .teal:
            return Text("Teal", comment: "Tint option")
        case .cyan:
            return Text("Cyan", comment: "Tint option")
        case .blue:
            return Text("Blue", comment: "Tint option")
        case .indigo:
            return Text("Indigo", comment: "Tint option")
        case .purple:
            return Text("Purple", comment: "Tint option")
        case .pink:
            return Text("Pink", comment: "Tint option")
        case .brown:
            return Text("Brown", comment: "Tint option")
        }
    }

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
