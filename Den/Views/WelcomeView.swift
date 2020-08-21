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
        VStack(spacing: 16) {
            Image("TitleIcon").resizable().scaledToFit().frame(width: 128, height: 128)
            Text("Welcome").font(.largeTitle)
        }
    }
}
