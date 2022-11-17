//
//  TopLevelBoardPaddingModifier.swift
//  Den
//
//  Created by Garrett Johnson on 10/12/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TopLevelBoardPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .padding(.top, 12)
            #endif
            .padding(.horizontal, 12)
            .padding(.bottom)
    }
}
