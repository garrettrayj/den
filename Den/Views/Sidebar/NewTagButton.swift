//
//  NewTagButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewTagButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            let newTag = Tag.create(in: viewContext, profile: profile)
            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("New Tag", comment: "Button label.")
            } icon: {
                Image(systemName: "tag")
            }
        }
        .accessibilityIdentifier("NewTag")
    }
}
