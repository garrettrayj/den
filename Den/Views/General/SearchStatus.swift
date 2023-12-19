//
//  SearchStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/19/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct SearchStatus: View {
    @Binding var searchQuery: String

    var body: some View {
        Text("Results for “\(searchQuery)”", comment: "Bottom bar status.").font(.caption)
    }
}
