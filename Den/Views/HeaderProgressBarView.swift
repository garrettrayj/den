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
    @ObservedObject var refreshable: Refreshable
    @State var observedProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: geometry.size.width, height: 2)
                
                if self.refreshManager.isRefreshing(self.refreshable) {
                    Rectangle()
                        .foregroundColor(Color.accentColor)
                        .frame(width: geometry.size.width * self.observedProgress, height: 2)
                        .animation(.linear)
                        .onReceive(self.refreshManager.progress.publisher(for: \.fractionCompleted).receive(on: RunLoop.main)) { fractionCompleted in
                            self.observedProgress = CGFloat(fractionCompleted)
                        }
                }
            }
        }
    }
}
