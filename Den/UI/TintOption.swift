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
            return Text("Red", comment: "Tint color option.")
        case .orange:
            return Text("Orange", comment: "Tint color option.")
        case .yellow:
            return Text("Yellow", comment: "Tint color option.")
        case .green:
            return Text("Green", comment: "Tint color option.")
        case .mint:
            return Text("Mint", comment: "Tint color option.")
        case .teal:
            return Text("Teal", comment: "Tint color option.")
        case .cyan:
            return Text("Cyan", comment: "Tint color option.")
        case .blue:
            return Text("Blue", comment: "Tint color option.")
        case .indigo:
            return Text("Indigo", comment: "Tint color option.")
        case .purple:
            return Text("Purple", comment: "Tint color option.")
        case .pink:
            return Text("Pink", comment: "Tint color option.")
        case .brown:
            return Text("Brown", comment: "Tint color option.")
        }
    }
    
    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .mint:
            return .mint
        case .teal:
            return .teal
        case .cyan:
            return .cyan
        case .blue:
            return .blue
        case .indigo:
            return .indigo
        case .purple:
            return .purple
        case .pink:
            return .pink
        case .brown:
            return .brown
        }
    }
}
