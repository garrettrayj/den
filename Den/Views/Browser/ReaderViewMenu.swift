//
//  ReaderViewMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/20/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ReaderViewMenu: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    var body: some View {
        Menu {
            ToggleReaderButton(browserViewModel: browserViewModel)
            ReaderZoom(browserViewModel: browserViewModel)
        } label: {
            Label {
                Text("View", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.plaintext.fill")
            }
        } primaryAction: {
            browserViewModel.toggleReader()
        }
        .accessibilityIdentifier("ReaderViewMenu")
    }
}
