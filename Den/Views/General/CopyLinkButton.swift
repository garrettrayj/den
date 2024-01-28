//
//  CopyLinkButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct CopyLinkButton: View {
    @Binding var url: URL?
    
    var body: some View {
        Button {
            guard let url = url else { return }
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
