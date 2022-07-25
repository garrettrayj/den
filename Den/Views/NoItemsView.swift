//
//  NoItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NoItemsView: View {
    var body: some View {
        StatusBoxView(
            message: Text("No Items"),
            symbol: "questionmark.folder"
        )
    }
}
