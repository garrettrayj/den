//
//  OrganizerInspectorConfig.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerOptionsPanel: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>

    var body: some View {
        if sources.isEmpty {
            Text("No Selection").font(.title)
        } else {
            Form {
                Section {
                    Picker(sources: sources, selection: \.itemLimitChoice) {
                        ForEach(ItemLimit.allCases, id: \.self) { choice in
                            Text("\(choice.rawValue)").tag(choice)
                        }
                    } label: {
                        Text("Preview Limit")
                    }
                    Toggle(sources: sources, isOn: \.browserView) {
                        Text("Open in Browser", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.readerMode) {
                        HStack(spacing: 4) {
                            Text("Reader Mode", comment: "Toggle label.")
                            Text("iOS")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(.quaternary)
                                )
                        }
                    }
                    Toggle(sources: sources, isOn: \.largePreviews) {
                        Text("Large Previews", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.hideTeasers) {
                        Text("Hide Teasers", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.hideBylines) {
                        Text("Hide Bylines", comment: "Toggle label.")
                    }
                    Toggle(sources: sources, isOn: \.hideImages) {
                        Text("Hide Images", comment: "Toggle label.")
                    }
                } header: {
                    Text("Previews")
                }

                Section {
                    Picker(sources: sources, selection: \.page) {
                        ForEach(profile.pagesArray) { page in
                            page.nameText.tag(page as Page?)
                        }
                    } label: {
                        Text("Page", comment: "Picker label.")
                    }
                } header: {
                    Text("Move")
                }

                Section {
                    Button(role: .destructive) {
                        selection.forEach { feed in
                            viewContext.delete(feed)
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
                            Text("Delete", comment: "Button label.")
                        } icon: {
                            Image(systemName: "trash")
                        }
                        .symbolRenderingMode(.multicolor)
                    }
                    .buttonStyle(.borderless)
                } header: {
                    Text("Danger Zone")
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
