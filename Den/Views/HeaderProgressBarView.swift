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
    
    var refreshables: [Refreshable]
    
    var body: some View {
        if self.refreshManager.isRefreshing(self.refreshables) {
            GeometryReader { geometry in
                Rectangle()
                    .foregroundColor(Color.accentColor)
                    .frame(width: geometry.size.width * self.observedProgress)
                    .animation(.linear)
                    .onReceive(self.refreshManager.progress.publisher(for: \.fractionCompleted).receive(on: RunLoop.main)) { fractionCompleted in
                        self.observedProgress = CGFloat(fractionCompleted)
                    }
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(height: 2)
            .clipped()
        }
    }
}
