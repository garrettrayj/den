//
//  BackNavigationModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BackNavigationModifier: ViewModifier {
    var title: String = "Back"

    func body(content: Content) -> some View {
        content
            #if targetEnvironment(macCatalyst)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButtonView(title: title)
                }
            }
            #endif
    }
}
