//
//  ImportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ImportButton: View {
    @Binding var showingImporter: Bool

    var body: some View {
        Button {
            showingImporter = true
        } label: {
            Label {
                Text("Import OPML", comment: "Button label.")
            } icon: {
                Image(systemName: "arrow.down.doc")
            }
        }
    }
}
