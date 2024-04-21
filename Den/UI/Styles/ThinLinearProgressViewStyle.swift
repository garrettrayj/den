//
//  ThinLinearProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 10/3/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ThinLinearProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(.fill.secondary)
                    Rectangle()
                        .fill(.tint)
                        .frame(width: fractionCompleted * geometry.size.width)
                        .animation(.linear, value: fractionCompleted)
                }
                .frame(height: 2)
            }
        }
    }
}
