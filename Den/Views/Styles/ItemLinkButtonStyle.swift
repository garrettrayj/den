//
//  ItemLinkButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemLinkButtonStyle: ButtonStyle {
    var read: Bool
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(read ? Color(UIColor.systemPurple) : Color(UIColor.link))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}
