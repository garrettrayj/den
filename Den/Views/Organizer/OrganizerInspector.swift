//
//  OrganizerInspector.swift
//  Den
//
//  Created by Garrett Johnson on 9/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerInspector: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>

    @State private var panel: String = "info"

    var sources: Binding<[Feed]> {
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

    var body: some View {
        VStack {
            Picker(selection: $panel) {
                Label {
                    Text("Info")
                } icon: {
                    Image(systemName: "info.circle")
                }.tag("info")
                Label {
                    Text("Configuration")
                } icon: {
                    Image(systemName: "slider.horizontal.3")
                }.tag("config")
            } label: {
                Text("View")
            }
            .labelsHidden()
            .labelStyle(.iconOnly)
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            if panel == "info" {
                if selection.count > 1 {
                    Spacer()
                    Text("Multiple Selected").font(.title).foregroundStyle(.tertiary)
                    Spacer()
                } else if let feed = selection.first {
                    List {
                        LabeledContent {
                            Text(verbatim: "\(feed.urlString)")
                        } label: {
                            Text("URL", comment: "Diagnostics header.")
                        }
                        if let feedData = feed.feedData {
                            LabeledContent {
                                if feed.urlString.lowercased().contains("https") {
                                    Text("Yes")
                                } else {
                                    Text("No")
                                }
                            } label: {
                                Text("Secure", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                if let format = feedData.format {
                                    Text(verbatim: "\(format)")
                                } else {
                                    Text("Not Available")
                                }
                            } label: {
                                Text("Format", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                Text("\(Int(feedData.responseTime * 1000)) ms")
                            } label: {
                                Text("Response Time", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                Text(verbatim: "\(feedData.httpStatus)")
                            } label: {
                                Text("Status", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                if let ageString = feedData.age, let age = Int(ageString) {
                                    Text("\(age) s")
                                } else {
                                    Text("Not Available")
                                }
                            } label: {
                                Text("Age", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                if let cacheControl = feedData.cacheControl {
                                    Text(verbatim: "\(cacheControl)")
                                } else {
                                    Text("Not Available")
                                }
                            } label: {
                                Text("Cache Control", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                if let eTag = feedData.eTag {
                                    Text(verbatim: "\(eTag)")
                                } else {
                                    Text("Not Available")
                                }
                            } label: {
                                Text("ETag", comment: "Diagnostics header.")
                            }
                            LabeledContent {
                                if let server = feedData.server {
                                    Text(verbatim: "\(server)")
                                } else {
                                    Text("Not Available")
                                }
                            } label: {
                                Text("Server", comment: "Diagnostics header.")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                } else {
                    Spacer()
                    Text("No Selection").font(.title).foregroundStyle(.tertiary)
                    Spacer()
                }
            } else if panel == "config" {
                if selection.count > 0 {
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
                                    if choice == .none {
                                        Text("Unlimited").tag(choice)
                                    } else {
                                        Text("\(choice.rawValue)").tag(choice)
                                    }
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
                } else {
                    Spacer()
                    Text("No Selection").font(.title).foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
    }
}
