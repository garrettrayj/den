//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: SubscribeViewModel

    var body: some View {
        Group {
            if viewModel.targetPage == nil {
                VStack(spacing: 24) {
                    Image(systemName: "questionmark.folder").font(.system(size: 52))
                    Text("No Pages Available").font(.title2)
                    Button { dismiss() } label: {
                        Text("Cancel").font(.title3)
                    }.buttonStyle(RegularButtonStyle())
                }
                .foregroundColor(.secondary)
            } else {
                NavigationView {
                    Form {
                        Section {
                            feedUrlInput
                        } header: {
                            Text("RSS or Atom URL")
                        } footer: {
                            if viewModel.validationMessage != nil {
                                Text(viewModel.validationMessage!)
                                    .font(.callout)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                    .padding([.top, .horizontal])
                                    .frame(maxWidth: .infinity)
                            }
                        }.modifier(SectionHeaderModifier())

                        submitButtonSection
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .feedRefreshed, object: viewModel.newFeed?.objectID)
                    ) { _ in
                        NotificationCenter.default.post(name: .pageRefreshed, object: viewModel.targetPage?.objectID)
                        dismiss()
                    }
                    .navigationTitle("Add Feed")
                    .toolbar {
                        ToolbarItem {
                            Button { dismiss() } label: {
                                Label("Close", systemImage: "xmark.circle")
                            }
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
    }

    private var submitButtonSection: some View {
        Button {
            viewModel.validateUrl()
            if viewModel.urlIsValid == true {
                viewModel.addFeed()
            }
        } label: {
            Label {
                Text("Add to \(viewModel.targetPage!.wrappedName)")
            } icon: {
                if viewModel.loading {
                    ProgressView().progressViewStyle(IconProgressStyle()).colorInvert()
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .listRowInsets(EdgeInsets())
        .disabled(!(viewModel.urlText.count > 0) || viewModel.loading)
        .buttonStyle(AccentButtonStyle())
    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $viewModel.urlText)
                .lineLimit(1)
                .disableAutocorrection(true)

            if viewModel.urlIsValid != nil {
                if viewModel.urlIsValid == true {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(UIColor.systemGreen))
                        .imageScale(.large)
                } else {
                    Image(systemName: "slash.circle")
                        .foregroundColor(Color(UIColor.systemRed))
                        .imageScale(.large)
                }
            }
        }
        .padding(.vertical, 4)
        .modifier(ShakeModifier(animatableData: CGFloat(viewModel.validationAttempts)))
    }
}
