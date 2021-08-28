//
//  SearchFieldView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchFieldView: View {
    @Binding var query: String

    var onCommit: () -> Void

    var body: some View {
        Group {
            HStack {
                Label(
                    title: {
                        TextField(
                            "Search",
                            text: $query,
                            onEditingChanged: {_ in },
                            onCommit: onCommit
                        ).padding(.vertical, 6)
                    },
                    icon: {
                        Image(systemName: "magnifyingglass")
                    }
                )

                if query != "" {
                    Button { query = "" } label: {
                        Label("Clear", systemImage: "multiply.circle.fill")
                            .foregroundColor(Color.secondary)
                            .labelStyle(IconOnlyLabelStyle())
                    }.layoutPriority(2)
                }
            }
            .padding(.leading, 12)
            .padding(.trailing, 8)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
        }
        .padding(8)
        .background(Color(UIColor.tertiarySystemBackground))
    }
}
