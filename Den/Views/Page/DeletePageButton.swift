//
//  DeletePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeletePageButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var page: Page
    
    var body: some View {
        Button(role: .destructive) {
            viewContext.delete(page)
        } label: {
            Label {
                Text("Delete Page", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.minus")
            }
            .symbolRenderingMode(.multicolor)
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeletePage")
    }
}
