//
//  NoItems.swift
//  Den
//
//  Created by Garrett Johnson on 7/22/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NoItems: View {
    var body: some View {
        SplashNote(
            Text("No Items", comment: "No available items message."),
            icon: { Image(systemName: "circle.slash").scaleEffect(x: -1, y: 1) }
        )
    }
}
