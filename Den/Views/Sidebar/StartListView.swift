//
//  StartListView.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct StartListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Panel?

    var body: some View {
        List(selection: $selection) {
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
                    Label("Add Page", systemImage: "plus")
                }
                .buttonStyle(.borderless)
                .modifier(StartRowModifier())
                .accessibilityIdentifier("start-add-page-button")

                Button {
                    loadDemo()
                } label: {
                    Label("Load Demo", systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderless)
                .modifier(StartRowModifier())
                .accessibilityIdentifier("load-demo-button")
            } header: {
                Text("Get Started")
            } footer: {
                Text("or import feeds in settings \(Image(systemName: "gear"))")
                    .imageScale(.small)
                    .padding(.top, 8)
            }
            .lineLimit(1)
        }
        .listStyle(.grouped)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    selection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(BottomBarButtonStyle())
                .accessibilityIdentifier("settings-button")
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
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
