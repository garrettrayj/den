//
//  IconSelector.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconSelector: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selection: String
    
    @State private var initialValue: String?
    @State private var showingManualEntry = false
    
    @FocusState private var textFieldFocus: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(
                    columns: [gridItem],
                    alignment: .center,
                    spacing: 4
                ) {
                    ForEach(PageIcon.allCases, id: \.self) { pageIcon in
                        ZStack {
                            RoundedRectangle(cornerRadius: 4).fill(.background)
                            if pageIcon.rawValue == selection {
                                Image(systemName: pageIcon.rawValue).foregroundStyle(.tint)
                                RoundedRectangle(cornerRadius: 4).strokeBorder(.tint, lineWidth: 2)
                            } else {
                                Image(systemName: pageIcon.rawValue)
                            }
                        }
                        .imageScale(.large)
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            showingManualEntry = false
                            selection = pageIcon.rawValue
                        }
                        .accessibilityIdentifier("PageIconOption")
                    }
                }
                .padding()
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Image(systemName: selection)
                        .imageScale(.large)
                        .foregroundStyle(.tint)
                        .frame(width: 40)

                    if showingManualEntry {
                        TextField(text: $selection) {
                            Text("Symbol", comment: "Text field label.")
                        }
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        #endif
                        .focused($textFieldFocus)
                        .onSubmit {
                            showingManualEntry = false
                        }
                    } else {
                        Button {
                            showingManualEntry.toggle()
                            textFieldFocus = true
                        } label: {
                            HStack {
                                Text(selection)
                                Image(systemName: "pencil")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                }
                .frame(height: 52)
                .padding(.horizontal)
                .background(.thinMaterial)
                .overlay(alignment: .bottom) {
                    Divider().opacity(0.75)
                }
                .lineLimit(1)
            }
            .onAppear {
                initialValue = selection
            }
            .navigationTitle(Text("Select Icon", comment: "Navigation title."))
            .toolbarBackground(.visible)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        if let initialValue = initialValue {
                            selection = initialValue
                        }
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                }
            }
        }
        .frame(minWidth: 360, minHeight: 480, idealHeight: 600, maxHeight: 800)
    }

    #if os(macOS)
    let gridItem = GridItem(.adaptive(minimum: 36), spacing: 4, alignment: .center)
    #else
    let gridItem = GridItem(.adaptive(minimum: 44), spacing: 4, alignment: .center)
    #endif
}
