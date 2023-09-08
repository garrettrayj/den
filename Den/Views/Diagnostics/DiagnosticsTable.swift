//
//  DiagnosticsTable.swift
//  Den
//
//  Created by Garrett Johnson on 7/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DiagnosticsTable: View {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @State var sortOrder = [KeyPathComparator(\DiagnosticsRowData.responseTime, order: .reverse)]
    @State var selection: DiagnosticsRowData.ID?
    @State var showingInspector: Bool = false

    var data: [DiagnosticsRowData] {
        profile.feedsArray.map { $0.diagnosticsRowData }.sorted(using: sortOrder)
    }

    var selected: DiagnosticsRowData? {
        data.first { $0.id == selection }
    }

    var body: some View {
        Table(data, selection: $selection, sortOrder: $sortOrder) {
            Group {
                TableColumn(
                    "Feed",
                    value: \DiagnosticsRowData.title
                ) { row in
                    #if os(macOS)
                    FeedTitleLabel(feed: row.entity)
                    #else
                    if horizontalSizeClass == .compact {
                        CompactDiagnosticsRow(data: row)
                    } else {
                        FeedTitleLabel(feed: row.entity)
                    }
                    #endif
                }
                .width(ideal: 180)

                TableColumn(
                    "Page",
                    value: \DiagnosticsRowData.page
                ) { row in
                    row.entity.page?.nameText ?? Text("Not Available", comment: "Page name not available.")
                }

                TableColumn(
                    "Address",
                    value: \.address
                ) { row in
                    Text(verbatim: "\(row.address)")
                }.width(ideal: 200)

                TableColumn(
                    "Secure",
                    value: \.isSecure
                ) { row in
                    if row.isSecure == 1 {
                        Text("Yes", comment: "Boolean value.")
                    } else {
                        Text("No", comment: "Boolean value.")
                    }
                }

                TableColumn(
                    "Format",
                    value: \.format
                )

                TableColumn(
                    "Response",
                    value: \.responseTime
                ) { row in
                    Text("\(row.responseTime) ms", comment: "Time display (milliseconds).")
                }

                TableColumn(
                    "Status",
                    value: \DiagnosticsRowData.httpStatus
                ) { row in
                    if row.httpStatus != -1 {
                        Text(verbatim: "\(row.httpStatus)")
                    }
                }
            }
        }
        .textSelection(.enabled)
        .navigationTitle(Text("Diagnostics", comment: "Navigation title."))
        .onChange(of: selection) {
            showingInspector = true
        }
        .inspector(isPresented: $showingInspector) {
            if let selected = selected {
                List {
                    Section {
                        LabeledContent {
                            if selected.age != -1 {
                                Text("\(selected.age) s")
                            } else {
                                Text("Not Available")
                            }
                        } label: {
                            Text("Age", comment: "Diagnostics header.")
                        }

                        LabeledContent {
                            if selected.cacheControl == "" {
                                Text("Not Available")
                            } else {
                                Text(verbatim: "\(selected.cacheControl)")
                            }
                        } label: {
                            Text("Cache Control", comment: "Diagnostics header.")
                        }

                        LabeledContent {
                            if selected.eTag == "" {
                                Text("Not Available")
                            } else {
                                Text(verbatim: "\(selected.eTag)")
                            }
                        } label: {
                            Text("ETag", comment: "Diagnostics header.")
                        }

                        LabeledContent {
                            if selected.server == "" {
                                Text("Not Available")
                            } else {
                                Text(verbatim: "\(selected.server)")
                            }
                        } label: {
                            Text("Server", comment: "Diagnostics header.")
                        }
                    } header: {
                        Text("Cache Info", comment: "Inspector section header.")
                    }
                }
            } else {
                Text("No Selection").font(.title3).foregroundStyle(.secondary)
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showingInspector.toggle()
                } label: {
                    Label {
                        Text("Inspector", comment: "Button label.")
                    } icon: {
                        Image(systemName: "sidebar.trailing")
                    }
                }
            }
        }
    }
}
