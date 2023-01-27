//
//  SearchableModifier.swift
//  Den
//
//  Created by Garrett Johnson on 1/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SearchableModifier: ViewModifier {
    @Environment(\.editMode) private var editMode

    @Binding var searchInput: String
    @Binding var contentSelection: ContentPanel?

    let searchModel: SearchModel

    func body(content: Content) -> some View {
        content
            .searchable(
                text: $searchInput,
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .onSubmit(of: .search) {
                searchModel.query = searchInput
                contentSelection = .search
            }
            .disabled(editMode?.wrappedValue == .active)
    }
}
