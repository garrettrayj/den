//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var profile: Profile

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "helm").font(.system(size: 52))
            Text("Welcome").font(.largeTitle)
            Spacer()
        }
        .multilineTextAlignment(.center)
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("Active Profile: \(profile.displayName)").font(.caption)
            }
        }
    }
}
