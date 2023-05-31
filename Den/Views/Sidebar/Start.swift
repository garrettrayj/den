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
            Button {
                _ = Page.create(in: viewContext, profile: profile, prepend: true)
                do {
                    try viewContext.save()
                    DispatchQueue.main.async {
                        profile.objectWillChange.send()
                    }
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            } label: {
                Label {
                    Text("New Page", comment: "Button label")
                        .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("start-add-page-button")

            Button {
                loadDemo()
            } label: {
                Label {
                    Text(
                        "Load Demo Feeds",
                        comment: "Button label"
                    )
                    .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemName: "wand.and.stars")
                }
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("load-demo-button")

            #if targetEnvironment(macCatalyst)
            importGuidanceText
                .font(.footnote)
                .foregroundColor(.secondary)
                .imageScale(.small)
                .padding(.vertical)
            #endif
        } header: {
            Text("Get Started", comment: "Sidebar section header")
        } footer: {
            importGuidanceText
                .font(.footnote)
                .foregroundColor(.secondary)
                .imageScale(.small)
                .padding(.vertical, 4)
        }
    }

    private var importGuidanceText: Text {
        Text(
            "Or import feeds in \(Image(systemName: "gear")) Settings.",
            comment: "Getting started guidance"
        )
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
            DispatchQueue.main.async {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
