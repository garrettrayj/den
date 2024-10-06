//
//  NewPageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NewPageSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var symbol: String = "folder"
    @State private var showingIconSelector: Bool = false
    
    @FocusState private var textFieldFocus: Bool
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var pages: FetchedResults<Page>

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Folder name placeholder.")
                    ) {
                        Label {
                            Text("Name", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                    .focused($textFieldFocus)
                }

                Section {
                    IconSelectorButton(showingIconSelector: $showingIconSelector, symbol: $symbol)
                        .sheet(isPresented: $showingIconSelector) {
                            IconSelector(selection: $symbol)
                        }
                }
            }
            .formStyle(.grouped)
            .onAppear {
                textFieldFocus = true
            }
            .navigationTitle(Text("New Folder", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let page = Page.create(in: viewContext, userOrder: pages.maxUserOrder + 1)
                        page.wrappedName = name
                        page.wrappedSymbol = symbol
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .accessibilityIdentifier("CreatePage")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 160)
        #endif
    }
}
