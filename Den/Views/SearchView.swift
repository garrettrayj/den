//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData
import Grid

struct SearchView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var searchManager: SearchManager
    @State private var isEditing = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                searchEntry
                searchResults
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.top, geometry.safeAreaInsets.top)
            .background(Color(UIColor.secondarySystemBackground))
            .edgesIgnoringSafeArea(.all)
            .navigationTitle(Text("Search"))
            .navigationBarTitleDisplayMode(.inline)
        }
        
        
    }
    
    var searchEntry: some View {
        
        ZStack {
            HStack {
                TextField(
                    "Search…",
                    text: $searchManager.query,
                    onEditingChanged: { changed in
                        self.isEditing = changed
                    },
                    onCommit: { self.isEditing = false }
                )
                    .font(Font.system(size: 18, design: .default))
                    .frame(height: 40)
                    .background(Color(UIColor.systemBackground))
            }
            .padding(.horizontal, 40)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.medium).foregroundColor(.secondary)
                Spacer()
                
                if isEditing && self.searchManager.query != "" {
                    Button(action: { self.searchManager.query = "" }) {
                        Image(systemName: "multiply.circle.fill")
                            .imageScale(.medium).foregroundColor(Color.secondary)
                    }.layoutPriority(2)
                }
            }.padding(.horizontal, 12)
        }.padding([.top, .horizontal])
    }
    
    var searchResults: some View {
        VStack(spacing: 0) {
            if searchManager.results.count > 0 && searchManager.searchIsValid(query: searchManager.query) {
                GeometryReader { geometry in
                    ScrollView {
                        Grid(self.searchManager.results, id: \.self) { sectionItems in
                            SearchResultView(items: sectionItems)
                        }
                        .gridStyle(StaggeredGridStyle(availableWidth: geometry.size.width))
                        .padding()
                        .padding(.bottom, 64)
                    }
                }
            } else if searchManager.query == "" {
                Text("Filter feeds and headlines by keyword").padding()
            } else if !searchManager.searchIsValid(query: searchManager.query) {
                Text("Minimum three characters required").padding()
            } else {
                Text("No results found").padding()
            }
        }
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
}
