//
//  SidebarItemLabelTextModifier.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarItemLabelTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .frame(height: 32)
            .padding(.leading, 6)
            .font(.system(size: 14))
            #endif
    }
}
