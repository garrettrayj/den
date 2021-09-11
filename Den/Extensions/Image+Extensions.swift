//
//  Image+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

extension Image {
    func thumbnail() -> some View {
        #if targetEnvironment(macCatalyst)
        self
            .resizable()
            .scaledToFill()
            .frame(width: 72, height: 48, alignment: .center)
        #else
        self
            .scaleEffect(1 / UIScreen.main.scale)
            .frame(width: 96, height: 64, alignment: .center)
        #endif
    }
}
