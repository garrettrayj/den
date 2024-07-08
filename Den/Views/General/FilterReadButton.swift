//
//  FilterReadButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FilterReadButton: View {
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        Button {
            withAnimation {
                hideRead.toggle()
            }
        } label: {
            Label {
                if hideRead {
                    Text("Show Read", comment: "Button label.")
                } else {
                    Text("Hide Read", comment: "Button label.")
                }
            } icon: {
                Image(systemName: "line.3.horizontal.decrease")
                    .symbolVariant(hideRead ? .circle.fill : .circle)
            }
        }
        .contentTransition(.symbolEffect(.replace))
        .help({
            if hideRead {
                Text("Show read items", comment: "Button help text.")
            } else {
                Text("Hide read items", comment: "Button help text.")
            }
        }())
        .accessibilityIdentifier("FilterRead")
    }
    
    init(storageKey: String? = nil) {
        if let storageKey {
            _hideRead = .init(wrappedValue: false, storageKey)
        }
    }
}
