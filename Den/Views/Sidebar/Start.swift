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

    @ObservedObject var profile: Profile

    var body: some View {
        Section {
            NewPageButton(activeProfile: .constant(profile))
                .buttonStyle(.borderless)

            Button {
                Task { loadDemo() }
            } label: {
                Label {
                    Text("Load Demo Feeds", comment: "Button label.")
                        .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: "wand.and.stars")
                }
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("load-demo-button")

            #if os(macOS)
            Text(
                "Or import OPML with File > Import.",
                comment: "Sidebar guidance message."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(.vertical)
            #endif
        } header: {
            Text("Get Started", comment: "Sidebar section header.")
        } footer: {
            Text(
                "Or import OPML in \(Image(systemName: "gear")) Settings.",
                comment: "Sidebar guidance message."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
            .imageScale(.small)
            .padding(.vertical, 4)
        }
    }

    private func loadDemo() {
        guard let demoPath = Bundle.main.path(forResource: "Demo", ofType: "opml") else {
            preconditionFailure("Missing demo feeds source file")
        }

        let symbolMap = [
            "World News": "globe",
            "US News": "newspaper",
            "Technology": "cpu",
            "Business": "briefcase",
            "Science": "atom",
            "Space": "sparkles",
            "Funnies": "face.smiling",
            "Curiosity": "person.and.arrow.left.and.arrow.right",
            "Design": "pyramid",
            "Gaming": "gamecontroller",
            "Entertainment": "film"
        ]

        let opmlReader = OPMLReader(xmlURL: URL(fileURLWithPath: demoPath))

        var newPages: [Page] = []
        opmlReader.outlineFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            page.symbol = symbolMap[opmlFolder.name]
            newPages.append(page)

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title
            }
        }

        do {
            try viewContext.save()
        } catch let error as NSError {
            CrashUtility.handleCriticalError(error)
        }
    }
}
