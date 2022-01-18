//
//  ToolbarLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 1/18/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Style used to correct spacing for toolbar items in the navigation bar.
 */
struct ToolbarLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.icon
            #if targetEnvironment(macCatalyst)
            .padding(.horizontal, 4)
            .offset(x: 4)
            #endif
    }
}
