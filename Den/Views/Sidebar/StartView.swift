//
//  StartView.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct StartView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var contentSelection: ContentPanel?

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
                Label("Add a New Page", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .modifier(StartRowModifier())
            .accessibilityIdentifier("start-add-page-button")
            Button {
                loadDemo()
            } label: {
                Label {
                    Text("Load Demo Pages")
                } icon: {
                    Image(systemName: "wand.and.stars")
                }
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, 8)
            .padding(.top, 4)
            .modifier(StartRowModifier())
            .accessibilityIdentifier("load-demo-button")
            
            Text("Or import feeds in \(Image(systemName: "gear")) Settings.")
                .font(.footnote)
                .foregroundColor(Color(.secondaryLabel))
                .imageScale(.small)
                .padding(.vertical, 8)
                .multilineTextAlignment(.center)
        } header: {
            Text("Get Started")
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
            DispatchQueue.main.async {
                CrashUtility.handleCriticalError(error)
            }
        }
    }
}
