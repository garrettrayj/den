//
//  ShakeAnimationModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/24/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShakeModifier: GeometryEffect {
    var amount: CGFloat = 12
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}
