//
//  PieProgressViewStyle.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PieProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .stroke(.secondary, lineWidth: 1.5)
            .overlay {
                PieShape(progress: configuration.fractionCompleted ?? 0)
                    .fill(.tertiary)
                    .padding(2)
            }
            .aspectRatio(1, contentMode: .fit)
    }
}

struct PieShape: Shape {
    var progress: Double = 0.0
    private let startAngle: Double = (Double.pi) * 1.5
    private var endAngle: Double {
        get {
            return self.startAngle + Double.pi * 2 * self.progress
        }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arcCenter =  CGPoint(x: rect.size.width / 2, y: rect.size.width / 2)
        let radius = rect.size.width / 2
        path.move(to: arcCenter)
        path.addArc(center: arcCenter, radius: radius, startAngle: Angle(radians: startAngle), endAngle: Angle(radians: endAngle), clockwise: false)
        path.closeSubpath()
        return path
    }
}
