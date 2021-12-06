//
//  IconProgressStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct IconProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        let view = ProgressView(configuration).progressViewStyle(CircularProgressViewStyle())

        #if targetEnvironment(macCatalyst)
        return view.scaleEffect(0.5, anchor: .center).frame(width: 16, height: 16, alignment: .center)
        #else
        return view
        #endif
    }
}
