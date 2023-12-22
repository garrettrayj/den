//
//  ReaderFormatMenu.swift
//  Den
//
//  Created by Garrett Johnson on 10/20/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ReaderFormatMenu: View {
    @ObservedObject var browserViewModel: BrowserViewModel
    
    var body: some View {
        Menu {
            HideReaderButton(browserViewModel: browserViewModel)
            ZoomControlGroup(zoomLevel: $browserViewModel.readerZoom)
        } label: {
            Label {
                Text("Formatting", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.plaintext.fill")
            }
        } primaryAction: {
            browserViewModel.toggleReader()
        }
    }
}
