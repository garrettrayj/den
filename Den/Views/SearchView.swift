//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

import Grid

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        ScrollView {
            if viewModel.queryIsValid == false {
                Text(viewModel.validationMessage ?? "Invalid search query")
                    .modifier(SimpleMessageModifier())
            } else if viewModel.queryIsValid == true {
                if viewModel.results.count > 0 {
                    Grid(viewModel.results, id: \.self) { sectionItems in
                        SearchResultView(contentViewModel: viewModel.contentViewModel, items: sectionItems)
                    }
                    .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 64)
                } else {
                    Text("No results found").modifier(SimpleMessageModifier())
                }
            } else {
                Text("Filter items by keyword").modifier(SimpleMessageModifier())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Search")
    }
}
