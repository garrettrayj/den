//
//  ImportButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImportButton: View {
    @SceneStorage("ShowingImporter") private var showingImporter: Bool = false

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
