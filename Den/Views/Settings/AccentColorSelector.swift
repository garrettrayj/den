//
//  AccentColorSelector.swift
//  Den
//
//  Created by Garrett Johnson on 3/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct AccentColorSelector: View {
    @Binding var selection: AccentColor?
    
    let gridItem = GridItem(.adaptive(minimum: 20), spacing: 4, alignment: .center)

    var body: some View {
        LabeledContent {
            LazyVGrid(columns: [gridItem], alignment: .center, spacing: 4) {
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
                    .padding(4)
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
            .frame(alignment: .trailing)
        } label: {
            Label {
                Text("Accent Color", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintbrush")
            }
        }
        .buttonStyle(.plain)
        .imageScale(.large)
    }
}
