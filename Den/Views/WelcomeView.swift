//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        StatusBoxView(
            message: "Welcome",
            symbol: "helm"
        ).navigationBarHidden(true)
    }
}
