//
//  PageIconCategory.swift
//  Den
//
//  Created by Garrett Johnson on 6/21/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

enum PageIconCategory: String, CaseIterable {
    case uncategorized = "uncategorized"
    case communication = "communication"
    case weather = "weather"
    case objectsandtools = "objectsandtools"
    case devices = "devices"
    case gaming = "gaming"
    case connectivity = "connectivity"
    case transportation = "transportation"
    case human = "human"
    case nature = "nature"
    case editing = "editing"
    case media = "media"
    case keyboard = "keyboard"
    case commerce = "commerce"
    case time = "time"
    case health = "health"
    case shapes = "shapes"
    case arrows = "arrows"
    case math = "math"

    var labelIcon: String {
        switch self {
        case .uncategorized:
            "square.grid.2x2"
        case .communication:
            "bubble.left"
        case .weather:
            "cloud.sun"
        case .objectsandtools:
            "folder"
        case .devices:
            "desktopcomputer"
        case .gaming:
            "gamecontroller"
        case .connectivity:
            "antenna.radiowaves.left.and.right"
        case .transportation:
            "car"
        case .human:
            "person.crop.circle"
        case .nature:
            "leaf"
        case .editing:
            "slider.horizontal.3"
        case .media:
            "playpause"
        case .keyboard:
            "keyboard"
        case .commerce:
            "cart"
        case .time:
            "timer"
        case .health:
            "heart"
        case .shapes:
            "square.on.circle"
        case .arrows:
            "arrow.right"
        case .math:
            "x.squareroot"
        }
    }

    var labelText: Text {
        switch self {
        case .uncategorized:
            Text("Uncategorized", comment: "Page icon category label.")
        case .communication:
            Text("Communication", comment: "Page icon category label.")
        case .weather:
            Text("Weather", comment: "Page icon category label.")
        case .objectsandtools:
            Text("Objects and Tools", comment: "Page icon category label.")
        case .devices:
            Text("Devices", comment: "Page icon category label.")
        case .gaming:
            Text("Gaming", comment: "Page icon category label.")
        case .connectivity:
            Text("Connectivity", comment: "Page icon category label.")
        case .transportation:
            Text("Transportation", comment: "Page icon category label.")
        case .human:
            Text("Human", comment: "Page icon category label.")
        case .nature:
            Text("Nature", comment: "Page icon category label.")
        case .editing:
            Text("Editing", comment: "Page icon category label.")
        case .media:
            Text("Media", comment: "Page icon category label.")
        case .keyboard:
            Text("Keyboard", comment: "Page icon category label.")
        case .commerce:
            Text("Commerce", comment: "Page icon category label.")
        case .time:
            Text("Time", comment: "Page icon category label.")
        case .health:
            Text("Health", comment: "Page icon category label.")
        case .shapes:
            Text("Shapes", comment: "Page icon category label.")
        case .arrows:
            Text("Arrows", comment: "Page icon category label.")
        case .math:
            Text("Math", comment: "Page icon category label.")
        }
    }
}
