//
//  StartListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct StartListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var showingSettings: Bool

    var body: some View {
        List {
            Section {
                Button(action: createPage) {
                    Label("Create Blank Page", systemImage: "plus")
                }
                .modifier(StartRowModifier())
                .accessibilityIdentifier("start-blank-page-button")

                Button(action: loadDemo) {
                    Label("Load Demo Feeds", systemImage: "wand.and.stars")
                }
                .modifier(StartRowModifier())
                .accessibilityIdentifier("load-demo-button")
            } header: {
                Text("Get Started")
            } footer: {
                Text("or import feeds in settings")
                #if targetEnvironment(macCatalyst)
                    .font(.system(size: 13)).padding(.vertical, 12)
                #endif
            }
            .lineLimit(1)
            .modifier(SectionHeaderModifier())
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }
                .accessibilityIdentifier("start-settings-button")
            }
        }
    }

    func loadDemo() {
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
            profile.objectWillChange.send()
        } catch let error as NSError {
            CrashManager.handleCriticalError(error)
        }
    }

    func save() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                CrashManager.handleCriticalError(error as NSError)
            }
        }
    }

    func createPage() {
        _ = Page.create(in: viewContext, profile: profile)
        save()
    }
}
