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
        ZStack {
            HStack {
                TextField("Search", text: $query, onEditingChanged: { edit in
                    print("edit: \(edit)")
                }, onCommit: onCommit)

                .frame(height: 32)
                .background(Color(UIColor.systemBackground))
            }
            .padding(.horizontal, 32)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)

            HStack {
                Image(systemName: "magnifyingglass").imageScale(.medium).foregroundColor(.secondary)
                Spacer()

                if query != "" {
                    Button { query = "" } label: {
                        Image(systemName: "multiply.circle.fill").imageScale(.medium).foregroundColor(Color.secondary)
                    }.layoutPriority(2)
                }
            }
            .padding(.horizontal, 12)
        }
        .padding(.horizontal, 16).padding(.bottom, 12).padding(.top, 12)
        .background(Color(UIColor.tertiarySystemBackground).edgesIgnoringSafeArea(.all))
    }
}
