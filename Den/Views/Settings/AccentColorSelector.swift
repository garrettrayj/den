//
//  AccentColorSelector.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AccentColorSelector: View {
    @Binding var selection: AccentColor?

    #if os(macOS)
    let columns = 6
    #else
    let columns = 4
    #endif

    var body: some View {
        LabeledContent {
            Grid(alignment: .topLeading) {
                GridRow {
                    Button {
                        selection = nil
                    } label: {
                        HStack {
                            if selection == nil {
                                Image(systemName: "checkmark.square")
                            } else {
                                Image(systemName: "square")
                            }
                            Text("System", comment: "Profile color option.").font(.callout)
                        }
                    }
                    .foregroundStyle(.secondary)
                    .gridCellColumns(columns)
                }

                Divider().gridCellUnsizedAxes(.horizontal)

                ForEach(AccentColor.allCases.chunked(by: columns), id: \.self) { options in
                    GridRow {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selection = option
                            } label: {
                                Label {
                                    option.labelText
                                } icon: {
                                    if selection == option {
                                        Image(systemName: "checkmark.square.fill")
                                    } else {
                                        Image(systemName: "square.fill")
                                    }
                                }
                                .foregroundStyle(option.color)
                                .labelStyle(.iconOnly)
                                .padding(.vertical, 2)
                            }
                        }
                    }
                }
            }
            .gridColumnAlignment(.leading)
            .buttonStyle(.plain)
            .imageScale(.large)
        } label: {
            Label {
                Text("Accent Color", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintbrush")
            }
        }
    }
}
