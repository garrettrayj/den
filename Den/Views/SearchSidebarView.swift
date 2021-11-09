//
//  SearchSidebarView.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchSidebarView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        VStack {
            Text("Current Items")
            Text("History")
        }
        .navigationTitle("Search")
    }
}
