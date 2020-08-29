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
            Spacer()
            if refreshManager.isRefreshing(refreshables) { // If loading, show the activity control
                ActivityRep()
                Text("Updating Feeds").font(.callout)
            } else if refreshManager.refreshing && !refreshManager.isRefreshing(refreshables) {
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
                
                lastRefreshedLabel()
            }
            Spacer()
        }
        .font(.callout)
        .foregroundColor(Color.secondary)
        .frame(height: height)
        .offset(y: -height + (refreshManager.isRefreshing(refreshables) ? +height : 0.0))
    }
    
    func lastRefreshedLabel() -> Text {
        var latestDate: Date? = nil
        
        refreshables.forEach { refreshable in
            guard let refreshed = refreshable.lastRefreshed else { return }
            
            if latestDate == nil {
                latestDate = refreshed
            } else if refreshed > latestDate! {
                latestDate = refreshed
            }
        }
        
        guard let lastRefreshed = latestDate else {
            return Text("Never Updated")
        }
        
        return Text("Last Updated \(lastRefreshed, formatter: DateFormatter.create())")
    }
}
