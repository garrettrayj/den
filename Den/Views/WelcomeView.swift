//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    var pages: FetchedResults<Page>
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 100, height: 100)
                Text("Welcome").font(.title).fontWeight(.semibold)
                Spacer()
            }.frame(height: 296)
        }
    }
}
