//
//  CopyLinkButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/2/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct CopyLinkButton: View {
    @Environment(\.openURL) private var openURL
    
    let url: URL
    
    var body: some View {
        Button {
            PasteboardUtility.copyURL(url: url)
        } label: {
            Label {
                Text("Copy Link", comment: "Button label.")
            } icon: {
                Image(systemName: "link.circle")
            }
        }
    }
}
