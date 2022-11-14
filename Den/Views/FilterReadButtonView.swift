//
//  FilterReadButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FilterReadButtonView: View {
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool
    
    var body: some View {
        Button {
            hideRead.toggle()
        } label: {
            Label(
                "Filter Read",
                systemImage: hideRead ?
                    "line.3.horizontal.decrease.circle.fill"
                    : "line.3.horizontal.decrease.circle"
            )
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("filter-read-button")
        .disabled(refreshing)
    }
}

