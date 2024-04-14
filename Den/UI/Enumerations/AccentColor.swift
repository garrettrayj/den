//
//  AccentColor.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

enum AccentColor: String, CaseIterable {
    case red
    case orange
    case yellow
    case green
    case mint
    case teal
    case cyan
    case blue
    case indigo
    case purple
    case pink
    case brown

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
    
    var labelText: Text {
        switch self {
        case .red:
            Text("Red", comment: "Accent color name.")
        case .orange:
            Text("Orange", comment: "Accent color name.")
        case .yellow:
            Text("Yellow", comment: "Accent color name.")
        case .green:
            Text("Green", comment: "Accent color name.")
        case .mint:
            Text("Mint", comment: "Accent color name.")
        case .teal:
            Text("Teal", comment: "Accent color name.")
        case .cyan:
            Text("Cyan", comment: "Accent color name.")
        case .blue:
            Text("Blue", comment: "Accent color name.")
        case .indigo:
            Text("Indigo", comment: "Accent color name.")
        case .purple:
            Text("Purple", comment: "Accent color name.")
        case .pink:
            Text("Pink", comment: "Accent color name.")
        case .brown:
            Text("Brown", comment: "Accent color name.")
        }
    }
}
