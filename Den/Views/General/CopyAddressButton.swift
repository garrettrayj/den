//
//  CopyAddressButton.swift
//  Den
//
//  Created by Garrett Johnson on 1/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CopyAddressButton: View {
    let url: URL
    
    var body: some View {
        Button {
            PasteboardUtility.copyURL(url: url)
        } label: {
            Label {
                Text("Copy Address", comment: "Button label.")
            } icon: {
                Image(systemName: "doc.on.doc")
            }
        }
    }
}
