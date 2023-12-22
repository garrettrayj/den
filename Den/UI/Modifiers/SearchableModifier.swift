//
//  SearchableModifier.swift
//  Den
//
//  Created by Garrett Johnson on 12/22/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct SearchableModifier: ViewModifier {
    @Binding var searchQuery: String

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .searchable(
                text: $searchQuery,
                prompt: Text("Search", comment: "Search field prompt.")
            )
            #else
            .searchable(
                text: $searchQuery,
                prompt: Text("Search", comment: "Search field prompt.")
            )
            #endif
    }
}
