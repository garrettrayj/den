//
//  TrendingLayout.swift
//  Den
//
//  Created by Garrett Johnson on 12/24/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct TrendingLayout: View {
    @ObservedObject var profile: Profile
    
    let trends: [Trend]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                BoardView(width: geometry.size.width, list: trends) { trend in
                    TrendBlock(profile: profile, trend: trend)
                }
            }
        }
    }
}
