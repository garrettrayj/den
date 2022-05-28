//
//  SubscribeView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SubscribeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: SubscribeViewModel

    var body: some View {
        Group {
            if viewModel.page == nil {
                VStack(spacing: 24) {
                    Image(systemName: "questionmark.folder").font(.system(size: 52))
                    Text("No Pages Available").font(.title2)
                    Button { dismiss() } label: {
                        Text("Cancel").font(.title3)
                    }
                    .accessibilityIdentifier("subscribe-cancel-button")
                }
                .foregroundColor(.secondary)
            } else {
                NavigationView {
                    Form {
                        Section {
                            feedUrlInput.modifier(FormRowModifier())
                        } header: {
                            Text("Web Address").frame(maxWidth: .infinity, alignment: .center)
                        } footer: {
                            Group {
                                if viewModel.validationMessage != nil {
                                    Text(viewModel.validationMessage!).foregroundColor(.red)
                                } else {
                                    Text("RSS, Atom, and JSON Feed formats accepted")
                                }
                            }
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            #if targetEnvironment(macCatalyst)
                            .padding(.top, 12)
                            #else
                            .padding(.top, 4)
                            #endif
                            .frame(maxWidth: .infinity)
                        }.headerProminence(.increased)

                        Section {
                            #if targetEnvironment(macCatalyst)
                            HStack {
                                pagePickerLabel
                                Spacer()
                                pagePicker.frame(width: 200)
                            }.modifier(FormRowModifier())
                            #else
                            pagePicker.modifier(FormRowModifier())
                            #endif
                        }

                        submitButtonSection
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .feedRefreshed, object: viewModel.newFeed?.objectID)
                    ) { _ in
                        viewModel.page?.objectWillChange.send()
                        dismiss()
                    }
                    .toolbar {
                        ToolbarItem {
                            Button { dismiss() } label: {
                                Label("Cancel", systemImage: "xmark.circle")
                            }
                            .accessibilityIdentifier("subscribe-cancel-button")
                        }
                    }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }

    private var submitButtonSection: some View {
        Button {
            viewModel.validateUrl()
            if viewModel.urlIsValid == true {
                viewModel.addFeed()
            }
        } label: {
            Label {
                Text("Add to \(viewModel.page!.wrappedName)")
            } icon: {
                if viewModel.loading {
                    ProgressView().progressViewStyle(IconProgressStyle()).colorInvert()
                } else {
                    Image(systemName: "note.text.badge.plus")
                }
            }.padding(.leading, 4)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color(UIColor.systemGroupedBackground))
        .disabled(!(viewModel.urlText.count > 0) || viewModel.loading)
        .modifier(ProminentButtonModifier())
        .accessibilityIdentifier("subscribe-submit-button")

    }

    private var feedUrlInput: some View {
        HStack {
            TextField("https://example.com/feed.xml", text: $viewModel.urlText)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .modifier(ShakeModifier(animatableData: CGFloat(viewModel.validationAttempts)))

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
    }

    private var pagePickerLabel: some View {
        Label("Page", systemImage: "target")
    }

    private var pagePicker: some View {
        Picker(selection: $viewModel.page) {
            ForEach(profileManager.activeProfile?.pagesArray ?? []) { page in
                Text(page.wrappedName).tag(page as Page?)
            }
            .navigationTitle("")
        } label: {
            pagePickerLabel
        }
    }
}
