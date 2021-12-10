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
        NavigationView {
            Form {
                if viewModel.destinationPage != nil {
                    Section {
                        feedUrlInput
                    } header: {
                        Text("RSS or Atom URL").modifier(SectionHeaderModifier())
                    } footer: {
                        if viewModel.validationMessage != nil {
                            Text(viewModel.validationMessage!)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding([.top, .horizontal])
                                .frame(maxWidth: .infinity)
                        }
                    }

                    submitButtonSection
                } else {
                    missingPage
                }
            }
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Add Source")
            .toolbar {
                ToolbarItem {
                    Button { dismiss() } label: {
                        Label("Close", systemImage: "xmark.circle")
                    }.buttonStyle(NavigationBarButtonStyle())
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: .feedRefreshed, object: viewModel.newFeed?.objectID)
            ) { _ in
                dismiss()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var submitButtonSection: some View {
        Button {
            viewModel.validateUrl()
            if viewModel.urlIsValid == true {
                viewModel.addSubscription()
            }
        } label: {
            Label {
                Text("Add to \(viewModel.destinationPage!.wrappedName)")
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

    private var missingPage: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text("Create a page before adding subscriptions")
                .foregroundColor(Color(.secondaryLabel))
                .multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity)
    }
}
