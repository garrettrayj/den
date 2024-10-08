//
//  ToggleReadFilterButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/13/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ToggleReadFilterButton: View {
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        Button {
            hideRead.toggle()
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
        .help(
            hideRead ? Text("Show read items", comment: "Button help text.") :
                Text("Hide read items", comment: "Button help text.")
        )
        .accessibilityIdentifier("ToggleReadFilter")
    }
}
