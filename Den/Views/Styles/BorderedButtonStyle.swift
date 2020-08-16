//
//  BorderedButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

struct BorderedButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .animation(Animation.linear(duration: 2))
            .overlay(
                RoundedRectangle(cornerRadius: 4).stroke(lineWidth: 1)
            )
            .foregroundColor(Color.accentColor)
            .opacity(configuration.isPressed ? 0.5 : 1.0 )
    }
}
