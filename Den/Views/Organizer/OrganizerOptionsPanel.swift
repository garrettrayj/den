//
//  OrganizerInspectorConfig.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct OrganizerOptionsPanel: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>

    var body: some View {
        if sources.isEmpty {
            Text("No Selection", comment: "Inspector selection message.").font(.title)
        } else {
            Form {
                Section {
                    Picker(sources: sources, selection: \.itemLimitChoice) {
                        ForEach(ItemLimit.allCases, id: \.self) { choice in
                            Text(verbatim: "\(choice.rawValue)").tag(choice)
                        }
                    } label: {
                        Text("Item Limit", comment: "Picker label.")
                    }
                    Toggle(sources: sources, isOn: \.largePreviews) {
                        Text("Large Previews", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showExcerpts) {
                        Text("Show Excerpts", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showBylines) {
                        Text("Show Bylines", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.showImages) {
                        Text("Show Images", comment: "Toggle label.")
                    }
                } header: {
                    Text("Previews", comment: "Inspector section header.")
                }

                Section {
                    Toggle(sources: sources, isOn: \.readerMode) {
                        Text("Use Reader Automatically", comment: "Toggle label.")
                    }
                    
                    Toggle(sources: sources, isOn: \.useBlocklists) {
                        Text("Use Blocklists", comment: "Toggle label.")
                    }
                    
                    Toggle(sources: sources, isOn: \.allowJavaScript) {
                        Text("Allow JavaScript", comment: "Toggle label.")
                    }
                } header: {
                    Text("Viewing", comment: "Inspector section header.")
                }

                Section {
                    Picker(sources: sources, selection: \.page) {
                        ForEach(profile.pagesArray) { page in
                            Text(page.wrappedName).tag(page as Page?)
                        }
                    } label: {
                        Text("Page", comment: "Picker label.")
                    }
                } header: {
                    Text("Move", comment: "Inspector section header.")
                }

                Section {
                    Button(role: .destructive) {
                        selection.forEach { feed in
                            viewContext.delete(feed)
                            if let feedData = feed.feedData { viewContext.delete(feedData) }
                            selection.remove(feed)
                        }
                        do {
                            try viewContext.save()
                            profile.pagesArray.forEach { $0.objectWillChange.send() }
                            profile.objectWillChange.send()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    } label: {
                        Label {
                            Text("Delete Feeds", comment: "Button label.")
                        } icon: {
                            Image(systemName: "trash")
                        }
                        .symbolRenderingMode(.multicolor)
                    }
                    .buttonStyle(.borderless)
                } header: {
                    Text("Management", comment: "Section header.")
                }
            }
        }
    }

    private var sources: Binding<[Feed]> {
        Binding(
            get: { selection.filter { _ in true } },
            set: {
                for feed in $0 where feed.changedValues().keys.contains("page") {
                    feed.userOrder = (feed.page?.feedsUserOrderMax ?? 0) + 1
                }
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                        profile.pagesArray.forEach { $0.objectWillChange.send() }
                        profile.objectWillChange.send()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        )
    }
}
