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
        content
            .font(.footnote)
            .textCase(.uppercase)
            .foregroundColor(.secondary)
    }
}
