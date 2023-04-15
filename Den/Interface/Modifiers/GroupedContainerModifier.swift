//
//  GroupedContainerModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GroupedContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.background)
    }
}
