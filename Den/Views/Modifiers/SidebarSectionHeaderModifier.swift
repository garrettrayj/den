//
//  SidebarSectionHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {

        #if targetEnvironment(macCatalyst)
        content
            .font(.title3.weight(.semibold))
            .padding(.vertical, 8)
        #else
        content.font(.title3.weight(.semibold))
        #endif
    }
}
