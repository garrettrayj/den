//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @FetchRequest(entity: Page.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)])
    var pages: FetchedResults<Page>
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 72, height: 72)
                Text("Welcome").font(.title).fontWeight(.semibold)
                if pages.count > 0 {
                    Text("Select a page to view feeds")
                }
                Spacer()
            }.frame(height: 296)
        }
    }
}
