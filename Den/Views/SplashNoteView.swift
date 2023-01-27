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
                Image(systemName: symbol)
                    .font(.system(size: 48))
                    .padding(.bottom, 8)
            }
            title
                .font(.title2.weight(.semibold))
            caption
                .font(.title3)
                .frame(maxWidth: 360)
                .padding(.horizontal)
                .foregroundColor(.secondary)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
