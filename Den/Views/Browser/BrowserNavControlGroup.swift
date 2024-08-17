//
//  BrowserNavControlGroup.swift
//  Den
//
//  Created by Garrett Johnson on 7/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserNavControlGroup: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    var body: some View {
        ControlGroup {
            GoBackButton(browserViewModel: browserViewModel)
            GoForwardButton(browserViewModel: browserViewModel)
        } label: {
            Text("Back/Forward", comment: "Control group label.")
        }
    }
}
