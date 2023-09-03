//
//  NewPageButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/19/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewPageButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            let newPage = Page.create(in: viewContext, profile: profile, prepend: true)
            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("New Page", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.plus")
            }
        }
        .accessibilityIdentifier("NewPage")
    }
}
