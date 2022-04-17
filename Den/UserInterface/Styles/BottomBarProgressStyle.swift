//
//  BottomBarProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BottomBarProgressStyle: ProgressViewStyle {
    let height: CGFloat = 6

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("Refreshing")
                configuration.currentValueLabel
            }.font(.footnote).foregroundColor(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(width: geometry.size.width, height: height)
                        .foregroundColor(Color(UIColor.tertiarySystemFill))

                    RoundedRectangle(cornerRadius: height / 2)
                        .frame(
                            width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width,
                            height: height
                        )
                        .foregroundColor(.accentColor)
                }
            }
        }
        .frame(idealWidth: 120)
        .padding(.bottom, 8)
    }
}
