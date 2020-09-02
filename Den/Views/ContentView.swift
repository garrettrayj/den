//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {    
    var body: some View {
        NavigationView {
            WorkspaceView()
            WelcomeView()
        }.background(Color(UIColor.systemBackground))
    }
}
