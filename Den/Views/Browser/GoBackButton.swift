//
//  GoBackButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GoBackButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    var body: some View {
        Button {
            browserViewModel.goBack()
        } label: {
            Label {
                Text("Go Back", comment: "Button label.")
            } icon: {
                Image(systemName: "chevron.backward")
            }
        }
        .disabled(!browserViewModel.canGoBack)
    }
}
