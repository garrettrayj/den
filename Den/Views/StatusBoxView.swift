//
//  StatusBoxView.swift
//  Den
//
//  Created by Garrett Johnson on 1/9/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StatusBoxView: View {
    var message: String
    var symbol: String?

    var body: some View {
        VStack(spacing: 24) {
            if symbol != nil {
                Image(systemName: symbol!).font(.system(size: 52))
            }
            Text(message)
        }
        .font(.title2)
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
