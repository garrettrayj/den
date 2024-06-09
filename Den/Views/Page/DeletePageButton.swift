//
//  DeletePageButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeletePageButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var page: Page

    var body: some View {
        Button(role: .destructive) {
            page.feedsArray.compactMap { $0.feedData }.forEach { modelContext.delete($0) }
            modelContext.delete(page)
        } label: {
            DeleteLabel()
        }
    }
}
