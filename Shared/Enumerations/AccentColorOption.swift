//
//  AccentColorOption.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

enum AccentColorOption: String, CaseIterable {
    case system
    case red
    case coral
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

    var color: Color? {
        switch self {
        case .system:
            return nil
        case .red:
            return .red
        case .coral:
            return .init("Coral")
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
        case .system:
            Text("System", comment: "Accent color option.")
        case .red:
            Text("Red", comment: "Accent color option.")
        case .coral:
            Text("Coral", comment: "Accent color option.")
        case .orange:
            Text("Orange", comment: "Accent color option.")
        case .yellow:
            Text("Yellow", comment: "Accent color option.")
        case .green:
            Text("Green", comment: "Accent color option.")
        case .mint:
            Text("Mint", comment: "Accent color option.")
        case .teal:
            Text("Teal", comment: "Accent color option.")
        case .cyan:
            Text("Cyan", comment: "Accent color option.")
        case .blue:
            Text("Blue", comment: "Accent color option.")
        case .indigo:
            Text("Indigo", comment: "Accent color option.")
        case .purple:
            Text("Purple", comment: "Accent color option.")
        case .pink:
            Text("Pink", comment: "Accent color option.")
        case .brown:
            Text("Brown", comment: "Accent color option.")
        }
    }
}
