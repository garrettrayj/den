//
//  Start.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Start: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        Section {
            NewPageButton()
            ImportButton()
            Button {
                loadDemo()
            } label: {
                Label {
                    Text("Load Demo", comment: "Button label.")
                        .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: "wand.and.stars")
                }
            }
            .accessibilityIdentifier("LoadDemo")
        } header: {
            Text("Get Started", comment: "Sidebar section header.")
        }
    }

    private func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        ImportExportUtility.importOPML(
            url: URL(fileURLWithPath: demoPath),
            context: viewContext, 
            pageUserOrderMax: 0
        )
    }
}
