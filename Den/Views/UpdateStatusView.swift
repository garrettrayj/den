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
    
    var page: Page
    var height: CGFloat
    var symbolRotation: Angle
    
    var body: some View {
        VStack {
            if refreshManager.pageIsRefreshing(page: page) { // If loading, show the activity control
                ActivityRep()
                Text("Updating feeds…")
            } else if symbolRotation > .degrees(0) && !refreshManager.pageIsRefreshing(page: page) {
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
        .offset(y: -height + (refreshManager.pageIsRefreshing(page: page) ? +height : 0.0))
    }
    
    func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = page.minimumRefreshedDate else {
            return Text("Never updated")
        }
        
        return Text("Updated \(lastRefreshed, formatter: DateFormatter.create())")
    }
}
