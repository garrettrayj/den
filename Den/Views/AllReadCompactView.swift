//
//  AllReadCompactView.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AllReadCompactView: View {
    let numHidden: Int

    var body: some View {
        Label {
            HStack {
                Text("All read")
                Spacer()
                Text("\(numHidden) hidden").font(.caption)
            }
        } icon: {
            Image(systemName: "checkmark")
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
    }
}
