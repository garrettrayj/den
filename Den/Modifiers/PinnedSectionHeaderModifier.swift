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
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            #if targetEnvironment(macCatalyst)
            .frame(height: 28)
            #else
            .frame(height: 36)
            #endif
            .padding(.horizontal, 20)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
    }
}
