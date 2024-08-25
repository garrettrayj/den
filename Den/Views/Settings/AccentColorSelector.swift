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
    @Binding var selection: AccentColorOption
    
    var body: some View {
        #if os(macOS)
        LabeledContent {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 20), spacing: 4, alignment: .center)],
                alignment: .center,
                spacing: 4
            ) {
                ForEach(AccentColorOption.allCases, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        if option == .system {
                            if selection == .system {
                                Image(systemName: "checkmark.square")
                            } else {
                                Image(systemName: "square")
                            }
                        } else if let color = option.color {
                            Group {
                                if selection == option {
                                    Image(systemName: "checkmark.square.fill")
                                } else {
                                    Image(systemName: "square.fill")
                                }
                            }
                            .foregroundStyle(color)
                        }
                    }
                }
            }
            .frame(maxWidth: 200, alignment: .trailing)
            .imageScale(.large)
        } label: {
            label
        }
        .buttonStyle(.plain)
        #else
        Picker(selection: $selection) {
            ForEach(AccentColorOption.allCases, id: \.self) { option in
                Group {
                    if option == .system {
                        Label {
                            option.labelText
                        } icon: {
                            Image(systemName: "square").imageScale(.large)
                        }
                        .foregroundStyle(.gray)
                    } else if let color = option.color {
                        Label {
                            option.labelText
                        } icon: {
                            Image(systemName: "square.fill").imageScale(.large)
                        }
                        .foregroundStyle(color)
                    }
                }
                .tag(option)
            }
        } label: {
            label
        }
        .pickerStyle(.navigationLink)
        #endif
    }
    
    private var label: some View {
        Label {
            Text("Accent Color", comment: "Picker label.")
        } icon: {
            Image(systemName: "paintbrush")
        }
    }
}
