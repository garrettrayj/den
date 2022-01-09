//
//  EditingListView.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct EditingListView: View {
    @ObservedObject var viewModel: ProfileViewModel

    @Binding var editingPages: Bool

    var body: some View {
        List {
            Section(
                header: HStack {
                    Text("\(viewModel.profile.pagesArray.count) Pages")
                    Spacer()
                    Text("Drag to Reorder")
                }
            ) {
                ForEach(viewModel.profile.pagesArray) { page in
                    Text(page.displayName)
                        .lineLimit(1)
                        #if targetEnvironment(macCatalyst)
                        .font(.title3)
                        .padding(.vertical, 8)
                        .padding(.leading, 6)
                        .listRowInsets(EdgeInsets())
                        #endif
                }
                .onMove(perform: viewModel.movePage)
                .onDelete(perform: viewModel.deletePage)
            }.modifier(SectionHeaderModifier())
        }
        #if targetEnvironment(macCatalyst)
        .listStyle(.grouped)
        .padding(.top, 10)
        #else
        .listStyle(.insetGrouped)
        #endif
        .environment(\.editMode, .constant(.active))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: viewModel.createPage) {
                    Label("New Page", systemImage: "plus")
                }.buttonStyle(NavigationBarButtonStyle())
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    editingPages = false
                } label: {
                    Text("Done").lineLimit(1)
                }.buttonStyle(NavigationBarButtonStyle())
            }
        }
    }
}
