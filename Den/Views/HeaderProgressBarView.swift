//
//  HeaderProgressBarView.swift
//  Den
//
//  Created by Garrett Johnson on 7/28/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct HeaderProgressBarView: View {
    @Binding var refreshing: Bool
    @Binding var fractionCompleted: CGFloat

    var body: some View {
        if refreshing {
            ProgressView(value: fractionCompleted)
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .progressViewStyle(SquaredLinearProgressViewStyle())
        }
    }
}
