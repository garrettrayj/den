//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var workspace: Workspace
    
    var body: some View {
        VStack {
            VStack(spacing: 16) {
                Image("TitleIcon").resizable().scaledToFit().frame(width: 72, height: 72)
                Text("Welcome").font(.title).fontWeight(.semibold)
                if !workspace.isEmpty {
                    Text("Select a page to view feeds")
                }
                Spacer()
            }.frame(height: 296)
        }
    }
}
