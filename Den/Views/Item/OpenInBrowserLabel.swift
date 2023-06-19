//
//  OpenInBrowserLabel.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OpenInBrowserLabel: View {
    var body: some View {
        Label {
            Text("Open in Browser", comment: "Button label.")
        } icon: {
            Image(systemName: "link.circle")
        }
    }
}

