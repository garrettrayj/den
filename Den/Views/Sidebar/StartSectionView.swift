//
//  StartSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StartSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.editMode) private var editMode
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
                    CrashManager.handleCriticalError(error as NSError)
                }
            } label: {
                Label("Create a blank page", systemImage: "plus")
            }
            .buttonStyle(.borderless)
            .modifier(StartRowModifier())
            .accessibilityIdentifier("start-blank-page-button")

            Button {
                loadDemo()
            } label: {
                Label("Load demo feeds", systemImage: "wand.and.stars")
            }
            .buttonStyle(.borderless)
            .modifier(StartRowModifier())
            .accessibilityIdentifier("load-demo-button")
        } header: {
            Text("Get Started")
        } footer: {
            Text("or import feeds in settings \(Image(systemName: "gear"))")
                .imageScale(.small)
                .padding(.top, 4)
        }
        .lineLimit(1)
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
                CrashManager.handleCriticalError(error)
            }
        }
    }
}
