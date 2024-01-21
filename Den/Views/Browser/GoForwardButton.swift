//
//  GoForwardButton.swift
//  Den
//
//  Created by Garrett Johnson on 10/19/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct GoForwardButton: View {
    @ObservedObject var browserViewModel: BrowserViewModel

    var body: some View {
        Button {
            browserViewModel.goForward()
        } label: {
            Label {
                Text("Go Forward", comment: "Button label.")
            } icon: {
                Image(systemName: "chevron.forward")
            }
        }
        .disabled(!browserViewModel.canGoForward)
    }
}
