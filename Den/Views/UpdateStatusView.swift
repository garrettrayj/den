//
//  RefreshView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct UpdateStatusView: View {
    @ObservedObject var updateManager: UpdateManager
    var height: CGFloat
    var symbolRotation: Angle
    
    var body: some View {
        Group {
            if updateManager.updating { // If loading, show the activity control
                VStack(alignment: .center) {
                    Spacer()
                    ActivityRep()
                    Text("Updating feeds...").font(.callout).foregroundColor(Color.secondary)
                    Spacer()
                }
                .frame(height: height)
                .offset(y: -height + (updateManager.updating ? height : 0.0))
            } else {
                // If not loading, show the arrow
                VStack {
                    Spacer()
                    Image(systemName: "arrow.down")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.secondary)
                        .frame(width: 16, height: 16)
                        .fixedSize()
                        .rotationEffect(symbolRotation)
                    Text(updateManager.refreshable.lastRefreshedLabel)
                        .font(.callout)
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
                .frame(height: height)
                .offset(y: -height + (updateManager.updating ? +height : 0.0))
            }
        }
    }
}
