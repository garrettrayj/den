//
//  ExportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/3/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ExportView: View {
    @EnvironmentObject var profileManager: ProfileManager

    @ObservedObject var viewModel: ExportViewModel

    var body: some View {
        VStack {
            if profileManager.activeProfileIsEmpty {
                StatusBoxView(message: "Profile Empty", symbol: "folder.badge.questionmark")
            } else {
                Form {
                    pageListSection

                    Section {
                        Button {
                            viewModel.exportOpml()
                        } label: {
                            Label("Export OPML", systemImage: "arrow.up.doc")
                        }
                        .buttonStyle(AccentButtonStyle())
                        .disabled(viewModel.selectedPages.count == 0)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Export")
    }

    private var pageListSection: some View {
        Section(header: selectionSectionHeader) {
            ForEach(profileManager.activeProfile!.pagesArray) { page in
                // .editMode doesn't work inside forms, so creating selection buttons manually
                Button { self.viewModel.togglePage(page) } label: {
                    Label(
                        title: {
                            HStack {
                                Text(page.wrappedName).foregroundColor(.primary)
                                Spacer()
                                Text("\(page.feeds!.count) feeds").foregroundColor(.secondary)
                            }

                        },
                        icon: {
                            if self.viewModel.selectedPages.contains(page) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }
                    )
                }
                .modifier(FormRowModifier())
                .onAppear { self.viewModel.selectedPages.append(page) }
            }
        }.modifier(SectionHeaderModifier())
    }

    private var selectionSectionHeader: some View {
        HStack {
            Text("Select Pages")
            Spacer()
            HStack {
                Button(action: viewModel.selectAll) { Text("All") }.disabled(viewModel.allSelected)
                Text("/")
                Button(action: viewModel.selectNone) { Text("None")}.disabled(viewModel.noneSelected)
            }.font(.callout)
        }
    }
}
