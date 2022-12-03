//
//  StatusView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var profile: Profile
    
    @Binding var refreshing: Bool
    
    let progress: Progress
    
    var body: some View {
        VStack {
            if refreshing {
                ProgressView(progress)
                    .progressViewStyle(BottomBarProgressStyle(progress: progress))
            } else if let refreshedDate = profile.minimumRefreshedDate {
                Text("\(refreshedDate.formatted())")
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh").imageScale(.small)
                #else
                Text("Pull to refresh")
                #endif
            }
        }
        .padding(.horizontal, 8)
        .lineLimit(1)
        .font(.caption)
        
    }
}
