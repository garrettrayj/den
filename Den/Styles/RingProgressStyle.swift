//
//  RingProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 12/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RingProgressStyle: ProgressViewStyle {
    @Binding var triggered: Bool

    var lineWidth: CGFloat = 5

    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            if triggered {
                ProgressView().progressViewStyle(.circular).scaleEffect(1.5)
            } else {
                Circle()
                    .stroke(lineWidth: lineWidth)
                    .foregroundColor(Color(UIColor.secondarySystemFill))

                Circle()
                    .trim(from: 0.0, to: CGFloat(min(configuration.fractionCompleted ?? 0, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(UIColor.systemFill))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: configuration.fractionCompleted)
            }
        }
        .opacity(min(configuration.fractionCompleted ?? 0 * 9, 1))
        .frame(width: 28, height: 28)
    }
}
