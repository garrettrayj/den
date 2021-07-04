//
//  ProgressBarView.swift
//  Den
//
//  Created by Garrett Johnson on 7/28/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import Combine

struct HeaderProgressBarView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @State var observedProgress: CGFloat = 0

    var page: Page

    var body: some View {
        if refreshManager.refreshing {
            ProgressView(value: observedProgress)
                .frame(maxWidth: .infinity)
                .frame(height: 4)
                .progressViewStyle(SquaredLinearProgressViewStyle())
                .onReceive(
                    self.refreshManager.progress
                        .publisher(for: \.fractionCompleted)
                        .receive(on: RunLoop.main)
                ) { fractionCompleted in
                    self.observedProgress = CGFloat(fractionCompleted)
                }
        }
    }
}
