//
//  PagePicker.swift
//  Den
//
//  Created by Garrett Johnson on 5/30/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct PagePicker: View {
    @ObservedObject var profile: Profile

    @Binding var selection: Page?

    var body: some View {
        Picker(selection: $selection) {
            ForEach(profile.pagesArray) { page in
                page.nameText.tag(page as Page?)
            }
        } label: {
            Label {
                Text("Page", comment: "Picker label.")
            } icon: {
                Image(systemName: "folder")
            }
        }
    }
}
