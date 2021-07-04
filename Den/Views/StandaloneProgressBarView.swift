//
//  StandaloneProgressBarView.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StandaloneProgressBarView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @State var observedProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule(style: .circular)
                    .foregroundColor(Color(UIColor.separator))
                    .frame(width: geometry.size.width, height: 8)

                Capsule(style: .circular)
                    .foregroundColor(Color.accentColor)
                    .frame(width: geometry.size.width * self.observedProgress, height: 8)
                    .animation(.linear)
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
}
