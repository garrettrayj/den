//
//  PagePicker.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PagePicker: View {
    @ObservedObject var profile: Profile

    @Binding var selection: Page?

    var body: some View {
        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Page").modifier(FormRowModifier())
            Spacer()
            Picker(selection: $selection) {
                ForEach(profile.pagesArray) { page in
                    Text(page.wrappedName).tag(page as Page?)
                }
            } label: {
                Text("Page")
            }
            .labelsHidden()
            .scaledToFit()
        }
        #else
        Picker(selection: $selection) {
            ForEach(profile.pagesArray) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
        } label: {
            Text("Page", comment: "Picker label").modifier(FormRowModifier())
        }
        #endif
    }
}
