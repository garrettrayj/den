//
//  NewBlocklistButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct NewBlocklistButton: View {
    @State private var showingSheet = false
    
    var body: some View {
        Button {
            showingSheet = true
        } label: {
            Label {
                Text("New Blocklist", comment: "Button label.")
            } icon: {
                Image(systemName: "plus")
            }
        }
        .accessibilityLabel("NewBlocklist")
        .sheet(isPresented: $showingSheet) {
            NewBlocklistSheet()
        }
    }
}
