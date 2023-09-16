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

struct ConfigInspector: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>

    var body: some View {
        Form {
            Section {
                Picker(sources: sources, selection: \.page) {
                    ForEach(profile.pagesArray) { page in
                        page.nameText.tag(page as Page?)
                    }
                } label: {
                    Text("Page", comment: "Picker label.")
                }
            }

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
        }
        .scrollContentBackground(.hidden)
        .padding(.horizontal, -8)
        .padding(.top, -4)
    }

    private var sources: Binding<[Feed]> {
        Binding(
            get: { selection.filter { _ in true } },
            set: {
                for (index, feed) in $0.enumerated() where feed.changedValues().keys.contains("page") {
                    feed.userOrder = (feed.page?.feedsUserOrderMax ?? 0) + Int16((index + 1))
                }

                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                        selection = Set($0)
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
