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
    
    var body: some View {
        #if os(macOS)
        LabeledContent {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 20), spacing: 4, alignment: .center)],
                alignment: .center,
                spacing: 4
            ) {
                Button {
                    selection = nil
                } label: {
                    Group {
                        if selection == nil {
                            Image(systemName: "checkmark.square")
                        } else {
                            Image(systemName: "square")
                        }
                    }
                }
                
                ForEach(AccentColor.allCases, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        Group {
                            if selection == option {
                                Image(systemName: "checkmark.square.fill")
                            } else {
                                Image(systemName: "square.fill")
                            }
                        }
                        .foregroundStyle(option.color)
                    }
                }
            }
            .frame(maxWidth: 200, alignment: .trailing)
            .imageScale(.large)
        } label: {
            Label {
                Text("Accent Color", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintbrush")
            }
        }
        .buttonStyle(.plain)
        #else
        Picker(selection: $selection) {
            Label {
                Text("Default", comment: "Accent color option.").foregroundStyle(.secondary)
            } icon: {
                Image(systemName: "square").foregroundStyle(.gray).imageScale(.large)
            }
            .tag(nil as AccentColor?)
            
            ForEach(AccentColor.allCases, id: \.self) { option in
                Label {
                    option.labelText.foregroundStyle(option.color)
                } icon: {
                    Image(systemName: "square.fill").foregroundStyle(option.color).imageScale(.large)
                }
                .tag(option as AccentColor?)
            }
        } label: {
            Label {
                Text("Accent Color", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintbrush")
            }
        }
        .pickerStyle(.navigationLink)
        #endif
    }
}
