//
//  PageIconCategory.swift
//  Den
//
//  Created by Garrett Johnson on 6/21/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

enum PageIconCategory: String, CaseIterable {
    // Note: String enum values can be omitted when they are equal to the enumcase name.
    case uncategorized
    case communication
    case weather
    case objectsandtools
    case devices
    case gaming
    case connectivity
    case transportation
    case human
    case nature
    case editing
    case media
    case keyboard
    case commerce
    case time
    case health
    case shapes
    case arrows
    case math

    var labelIcon: String {
        switch self {
        case .uncategorized:
            return "square.grid.2x2"
        case .communication:
            return "bubble.left"
        case .weather:
            return "cloud.sun"
        case .objectsandtools:
            return "folder"
        case .devices:
            return "desktopcomputer"
        case .gaming:
            return "gamecontroller"
        case .connectivity:
            return "antenna.radiowaves.left.and.right"
        case .transportation:
            return "car"
        case .human:
            return "person.crop.circle"
        case .nature:
            return "leaf"
        case .editing:
            return "slider.horizontal.3"
        case .media:
            return "playpause"
        case .keyboard:
            return "keyboard"
        case .commerce:
            return "cart"
        case .time:
            return "timer"
        case .health:
            return "heart"
        case .shapes:
            return "square.on.circle"
        case .arrows:
            return "arrow.right"
        case .math:
            return "x.squareroot"
        }
    }

    var labelText: Text {
        switch self {
        case .uncategorized:
            return Text("Uncategorized", comment: "Page icon category label.")
        case .communication:
            return Text("Communication", comment: "Page icon category label.")
        case .weather:
            return Text("Weather", comment: "Page icon category label.")
        case .objectsandtools:
            return Text("Objects and Tools", comment: "Page icon category label.")
        case .devices:
            return Text("Devices", comment: "Page icon category label.")
        case .gaming:
            return Text("Gaming", comment: "Page icon category label.")
        case .connectivity:
            return Text("Connectivity", comment: "Page icon category label.")
        case .transportation:
            return Text("Transportation", comment: "Page icon category label.")
        case .human:
            return Text("Human", comment: "Page icon category label.")
        case .nature:
            return Text("Nature", comment: "Page icon category label.")
        case .editing:
            return Text("Editing", comment: "Page icon category label.")
        case .media:
            return Text("Media", comment: "Page icon category label.")
        case .keyboard:
            return Text("Keyboard", comment: "Page icon category label.")
        case .commerce:
            return Text("Commerce", comment: "Page icon category label.")
        case .time:
            return Text("Time", comment: "Page icon category label.")
        case .health:
            return Text("Health", comment: "Page icon category label.")
        case .shapes:
            return Text("Shapes", comment: "Page icon category label.")
        case .arrows:
            return Text("Arrows", comment: "Page icon category label.")
        case .math:
            return Text("Math", comment: "Page icon category label.")
        }
    }
}
