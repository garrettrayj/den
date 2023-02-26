//
//  StartListView.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct StartListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var contentSelection: ContentPanel?

    @State private var useBigDemo: Bool = false

    var body: some View {
        List(selection: $contentSelection) {
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
                .modifier(StartRowModifier())
                .accessibilityIdentifier("load-demo-button")

                Toggle(isOn: $useBigDemo) {
                    Text("More feeds?").foregroundColor(.secondary)
                }
                .font(.footnote)
                #if targetEnvironment(macCatalyst)
                .padding(.leading, 32)
                #else
                .padding(.leading, 44)
                #endif
            } header: {
                Text("Get Started")
            } footer: {
                Text("Or import feeds in settings. \(Image(systemName: "gear"))")
                    .imageScale(.small)
                    .padding(.top, 8)
            }
            .lineLimit(1)
        }
        .listStyle(.insetGrouped)
        .navigationTitle(profile.displayName)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    contentSelection = .settings
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                .buttonStyle(PlainToolbarButtonStyle())
                .accessibilityIdentifier("settings-button")
            }
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
        }
    }

    private func loadDemo() {
        var demoFileBaseName = "Demo"
        if useBigDemo {
            demoFileBaseName = "BigDemo"
        }

        guard let demoPath = Bundle.main.path(forResource: demoFileBaseName, ofType: "opml") else {
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
