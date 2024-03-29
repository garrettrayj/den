//
//  NewProfileButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewProfileButton: View {
    @State private var showingSheet = false
    
    var callback: ((Profile) -> Void)?

    var body: some View {
        Button {
            showingSheet = true
        } label: {
            Label {
                Text("New Profile", comment: "Button label.").lineLimit(1)
            } icon: {
                Image(systemName: "plus")
            }
        }
        .accessibilityIdentifier("NewProfile")
        .sheet(
            isPresented: $showingSheet,
            content: {
                NewProfileSheet(callback: callback).multilineTextAlignment(.leading)
            }
        )
    }
}
