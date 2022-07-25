//
//  AllReadView.swift
//  Den
//
//  Created by Garrett Johnson on 7/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AllReadView: View {
    let hiddenItemCount: Int

    var body: some View {
        StatusBoxView(
            message: Text("All Read"),
            caption: Text("\(hiddenItemCount) items hidden"),
            symbol: "checkmark"
        )
    }
}
