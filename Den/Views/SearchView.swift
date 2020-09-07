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
        VStack(spacing: 0) {
            Divider()
            VStack {
                TextField("Search…", text: $searchManager.query)
                .font(Font.system(size: 18, design: .default))
                .frame(height: 36)
                .padding(.leading, 36)
                .padding(.trailing, 16)
                .background(Color(UIColor.systemBackground))
                .onTapGesture {
                    self.isEditing = true
                }
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18, height: 18)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if isEditing {
                            Button(action: {
                                self.searchManager.query = ""
                            }) {
                                Image(systemName: "multiply.circle.fill").titleBarIconView().foregroundColor(Color.secondary)
                            }.offset(x: 12)
                        }
                    }.padding(.horizontal, 12)
                )
                .cornerRadius(8)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.tertiarySystemBackground))
            
            
            Divider()
            
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
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationBarTitle("Search", displayMode: .inline)
    }
}
