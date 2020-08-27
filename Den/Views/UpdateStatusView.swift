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
        VStack {
            Spacer()
            if refreshManager.isRefreshing(refreshable) { // If loading, show the activity control
                ActivityRep()
                Text("Updating Feeds").font(.callout)
            } else if refreshManager.refreshing && !refreshManager.isRefreshing(refreshable) {
                Image(systemName: "slash.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                Text("Other Operation in Progress")
            } else {
                Image(systemName: "arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .fixedSize()
                    .rotationEffect(symbolRotation)
                
                if refreshable.lastRefreshed != nil {
                    Text("Last Refreshed \(refreshable.lastRefreshed!, formatter: DateFormatter.create())").lineLimit(1)
                } else {
                    Text("Never Refreshed")
                }
            }
            Spacer()
        }
        .font(.callout)
        .foregroundColor(Color.secondary)
        .frame(height: height)
        .offset(y: -height + (refreshManager.isRefreshing(refreshable) ? +height : 0.0))
    }
}
