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
        Group {
            if workspace.pageArray.first != nil {
                PageView(page: workspace.pageArray.first!)
            } else {
                VStack {
                    Text("Welcome").font(.largeTitle)
                }
            }
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(workspace: Workspace())
    }
}
