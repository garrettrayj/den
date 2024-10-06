//
//  WidgetAppIcon.swift
//  Den
//
//  Created by Garrett Johnson on 10/5/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WidgetAppIcon: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    
    @ScaledMetric(relativeTo: .largeTitle) var size = 16
    
    var body: some View {
        Group {
            if #available(iOS 18.0, macOS 15.0, *) {
                if widgetRenderingMode == .fullColor {
                    Rectangle()
                        .fill(.tint)
                        .mask(alignment: .center) {
                            Image("WidgetIcon")
                                .resizable()
                                .scaledToFit()
                        }
                } else {
                    Image("WidgetIcon")
                        .resizable()
                        .widgetAccentedRenderingMode(.accentedDesaturated)
                }
            } else {
                Rectangle()
                    .fill(.tint)
                    .mask(alignment: .center) {
                        Image("WidgetIcon")
                            .resizable()
                            .scaledToFit()
                    }
            }
        }
        .frame(width: size, height: size)
        .offset(y: -2)
    }
}
