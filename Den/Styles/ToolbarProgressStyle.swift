//
//  NavigationBarProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Indederminate circular ProgressViewStyle for use in place of toolbar buttons.
 */
struct ToolbarProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let view = ProgressView(configuration).progressViewStyle(CircularProgressViewStyle())

        #if targetEnvironment(macCatalyst)
        return view.scaleEffect(0.6).frame(width: 17, alignment: .trailing).padding(.horizontal, 4)
        #else
        return view.scaleEffect(1.25).frame(width: 22, alignment: .trailing)
        #endif
    }
}
