//
//  StatusBoxView.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StatusBoxView: View {
    var message: Text
    var caption: Text?
    var symbol: String?

    var body: some View {
        VStack(spacing: 24) {
            if symbol != nil {
                Image(systemName: symbol!).font(.system(size: 52))
            }
            message.font(.title2)
            caption.font(.title3)
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    init(
        message: Text,
        caption: Text? = nil,
        symbol: String? = nil
    ) {
        self.message = message
        self.caption = caption
        self.symbol = symbol
    }
}
