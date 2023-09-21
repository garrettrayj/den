//
//  BorderedCardContainer.swift
//  Den
//
//  Created by Garrett Johnson on 9/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BorderedCardContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        HStack {
            Spacer()
            content()
            Spacer()
        }
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 8).strokeBorder(.separator, lineWidth: 1)
        )
    }
}
