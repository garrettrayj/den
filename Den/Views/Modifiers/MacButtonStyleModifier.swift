//
//  MacButtonStyleModifier.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Modifier to apply a default button style. Usually added to top level views, e.g. ContentView
 
 Catalyst out-of-the-box uses a more plain button style than iOS. The state doesn't change
 when the button is pressed, primary font color, etc. Using BorderlessButtonStyle is a better
 user experience on Mac, but applying a button style on iOS interferes with tappable area
 and row highlighting.
 */
struct MacButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content.buttonStyle(BorderlessButtonStyle())
        #else
        content
        #endif
    }
}
