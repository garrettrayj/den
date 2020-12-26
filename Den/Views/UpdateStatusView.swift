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
    
    var refreshables: [Refreshable]
    var height: CGFloat
    var symbolRotation: Angle
    
    var body: some View {
        VStack {
            if refreshManager.isRefreshing(refreshables) { // If loading, show the activity control
                ActivityRep()
                Text("Updating feeds…")
            } else if refreshManager.refreshing && !refreshManager.isRefreshing(refreshables) {
                Image(systemName: "slash.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text("Other refresh in progress")
            } else if symbolRotation > .degrees(0) {
                Image(systemName: "arrow.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                    .fixedSize()
                    .rotationEffect(symbolRotation)
                
                lastRefreshedLabel()
            }
        }
        .font(.callout)
        .foregroundColor(Color.secondary)
        .fixedSize()
        .frame(height: height)
        .offset(y: -height + (refreshManager.isRefreshing(refreshables) ? +height : 0.0))
    }
    
    func lastRefreshedLabel() -> Text {
        var earliestRefreshDate: Date? = nil
        
        refreshables.forEach { refreshable in
            guard let refreshed = refreshable.lastRefreshed else { return }
            if earliestRefreshDate == nil  || refreshed < earliestRefreshDate! {
                earliestRefreshDate = refreshed
            }
        }
        
        guard let lastRefreshed = earliestRefreshDate else {
            return Text("Never updated")
        }
        
        return Text("Updated \(lastRefreshed, formatter: DateFormatter.create())")
    }
}
