//
//  SearchFieldView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SearchFieldView: View {
    @Binding var searchQuery: String
    
    var body: some View {
        ZStack {
            HStack {
                TextField(
                    "Search…",
                    text: $searchQuery
                )
                .font(Font.system(size: 18, design: .default))
                .frame(height: 40)
                .background(Color(UIColor.systemBackground))
            }
            .padding(.horizontal, 44)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            
            HStack {
                Image(systemName: "magnifyingglass").imageScale(.medium).foregroundColor(.secondary)
                Spacer()
                
                if self.searchQuery != "" {
                    Button(action: reset) {
                        Image(systemName: "multiply.circle.fill").imageScale(.medium).foregroundColor(Color.secondary)
                    }.layoutPriority(2)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.horizontal, 16).padding(.bottom, 12).padding(.top, 12)
        .background(Color(UIColor.tertiarySystemBackground).edgesIgnoringSafeArea(.all))
    }
    
    private func reset() {
        self.searchQuery = ""
    }
}
