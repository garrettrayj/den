//
//  SectionHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content.listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
        #else
        content
        #endif
    }
}
