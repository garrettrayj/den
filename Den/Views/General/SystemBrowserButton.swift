//
//  SystemBrowserButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct SystemBrowserButton: View {
    @Environment(\.openURL) private var openURL
    
    @Binding var url: URL?
    
    var body: some View {
        Button {
            guard let url = url else { return }
            openURL(url)
        } label: {
            Label {
                Text("Open in Browser", comment: "Button label.")
            } icon: {
                Image(systemName: "link.circle")
            }
        }
    }
}
