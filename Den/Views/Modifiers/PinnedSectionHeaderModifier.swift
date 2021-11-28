//
//  PinnedSectionHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PinnedSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            content
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color(UIColor.tertiarySystemGroupedBackground))

            Divider()
        }

    }
}
