//
//  SplashNoteView.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SplashNoteView: View {
    let title: Text
    var caption: Text?
    var symbol: String?

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            if let symbol = symbol {
                Image(systemName: symbol).font(.system(size: 28))
            }
            title.font(.title)
            caption.padding(.horizontal)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(24)
    }
}
