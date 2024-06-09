//
//  DeleteTagButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteTagButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var tag: Tag

    var body: some View {
        Button(role: .destructive) {
            modelContext.delete(tag)
        } label: {
            DeleteLabel()
        }
        .buttonStyle(.borderless)
        .accessibilityIdentifier("DeleteTag")
    }
}
