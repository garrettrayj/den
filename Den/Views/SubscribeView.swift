//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.presentationMode) var presentationMode

    @ObservedObject var viewModel: SubscribeViewModel

    var body: some View {
        NavigationView {
            Form {
                if viewModel.destinationPage != nil {
                    feedUrlSection
                    submitButtonSection

                } else {
                    missingPage
                }
            }
            .navigationTitle("Add Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button { presentationMode.wrappedValue.dismiss() } label: {
                        Label("Close", systemImage: "xmark.circle")
                    }.buttonStyle(ToolbarButtonStyle())
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var feedUrlSection: some View {
        Section(
            header: Text("Feed URL"),
            footer: Group {
                if viewModel.validationMessage != nil {
                    Text(viewModel.validationMessage!)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
        ) {
            feedUrlInput
        }
    }

    private var submitButtonSection: some View {
        Section {
            Button {
                viewModel.validateUrl()
                if viewModel.urlIsValid == true {
                    viewModel.addSubscription {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } label: {
                Label(
                    title: { Text("Add to \(viewModel.destinationPage!.wrappedName)") },
                    icon: {
                        if viewModel.loading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "plus")
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color(UIColor.systemGroupedBackground))
            .disabled(!(viewModel.urlText.count > 0) || viewModel.loading)
            .buttonStyle(AccentButtonStyle())
        }
    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $viewModel.urlText)
                .lineLimit(1)
                .disableAutocorrection(true)
                .padding(.vertical, 4)

            if viewModel.urlIsValid != nil {
                if viewModel.urlIsValid == true {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(Color(UIColor.systemGreen))
                } else {
                    Image(systemName: "slash.circle")
                        .foregroundColor(Color(UIColor.systemRed))
                }
            }
        }
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

    private func close() {
        self.presentationMode.wrappedValue.dismiss()
    }
}
