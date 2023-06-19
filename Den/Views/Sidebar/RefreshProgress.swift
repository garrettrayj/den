//
//  RefreshProgress.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RefreshProgress: View {
    @State private var progress = Progress()
    
    init(totalUnitCount: Int) {
        self.progress.totalUnitCount = Int64(totalUnitCount)
    }
    
    var body: some View {
        ProgressView(progress)
            .progressViewStyle(PieProgressViewStyle())
            #if os(macOS)
            .frame(width: 30, height: 16)
            #endif
            .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                progress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
                progress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshFinished)) { _ in
                progress.completedUnitCount = 0
            }
    }
}

