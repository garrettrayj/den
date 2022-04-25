//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: ExportViewModel

    var body: some View {
        VStack {
            if profileManager.activeProfileIsEmpty {
                StatusBoxView(message: Text("Profile Empty"), symbol: "folder.badge.questionmark")
            } else {
                Form {
                    pageListSection

                    Section {
                        Button {
                            viewModel.exportOpml()
                        } label: {
                            Label("Save OPML File", systemImage: "arrow.up.doc").labelStyle(.titleAndIcon)
                        }
                        .modifier(ProminentButtonModifier())
                        .disabled(viewModel.selectedPages.isEmpty)
                        .accessibilityIdentifier("export-opml-button")
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Export")
        .modifier(BackNavigationModifier(title: "Settings"))
    }

    private var pageListSection: some View {
        Section(header: selectionSectionHeader) {
            ForEach(profileManager.activeProfile!.pagesArray) { page in
                // .editMode doesn't work inside forms, so creating selection buttons manually
                Button { self.viewModel.togglePage(page) } label: {
                    Label {
                        HStack {
                            Text(page.wrappedName).foregroundColor(.primary)
                            Spacer()
                            Text("\(page.feeds?.count ?? 0) feeds")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                        }
                    } icon: {
                        if self.viewModel.selectedPages.contains(page) {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }.lineLimit(1)
                }
                .modifier(FormRowModifier())
                .onAppear { self.viewModel.selectedPages.append(page) }
                .accessibilityIdentifier("export-toggle-page-button")
            }
        }.modifier(SectionHeaderModifier())
    }

    private var selectionSectionHeader: some View {
        HStack {
            Text("Select")
            Spacer()
            HStack {
                Button(action: viewModel.selectAll) { Text("All") }
                    .disabled(viewModel.allSelected)
                    .accessibilityIdentifier("export-select-all-button")
                Text("/").foregroundColor(.secondary)
                Button(action: viewModel.selectNone) { Text("None")}
                    .disabled(viewModel.noneSelected)
                    .accessibilityIdentifier("export-select-none-button")
            }
            .font(.system(size: 12))
        }
    }
}
