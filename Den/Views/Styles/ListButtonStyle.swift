//
//  ListButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 6/25/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ListButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .overlay(configuration.isPressed ? Color.red.opacity(0.4) : Color.clear)
    }
}
