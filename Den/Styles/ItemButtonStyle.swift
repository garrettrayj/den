//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemButtonStyle: ButtonStyle {
    var read: Bool

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title3)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(read ? Color(UIColor.systemPurple) : Color(UIColor.link))
            .modifier(HoverPointingModifier())
    }
}
