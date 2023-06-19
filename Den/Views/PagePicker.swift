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

    let labelText: Text

    var body: some View {
        Picker(selection: $selection) {
            ForEach(profile.pagesArray) { page in
                page.nameText.tag(page as Page?)
            }
        } label: {
            Label {
                labelText
            } icon: {
                Image(systemName: "folder")
            }
        }
    }
}
