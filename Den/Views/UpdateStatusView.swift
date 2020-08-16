//
//  RefreshView.swift
//  Den
//
//  Created by Garrett Johnson on 7/1/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//
import Foundation
import SwiftUI

struct UpdateStatusView: View {
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var refreshable: Refreshable
    
    var height: CGFloat
    var symbolRotation: Angle
    
    var body: some View {
        Group {
            if refreshManager.isRefreshing(refreshable) { // If loading, show the activity control
                VStack(alignment: .center) {
                    Spacer()
                    ActivityRep()
                    Text("Updating feeds...").font(.callout).foregroundColor(Color.secondary)
                    Spacer()
                }
                .frame(height: height)
                .offset(y: -height + (refreshManager.isRefreshing(refreshable) ? height : 0.0))
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
                    Text(refreshable.lastRefreshedLabel)
                        .font(.callout)
                        .foregroundColor(Color.secondary)
                    Spacer()
                }
                .frame(height: height)
                .offset(y: -height + (refreshManager.isRefreshing(refreshable) ? +height : 0.0))
            }
        }
    }
}
