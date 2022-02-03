//
//  SecurityCheckView.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SecurityCheckView: View {
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: SecurityCheckViewModel

    var body: some View {
        List {
            if profileManager.activeProfile?.insecureFeedCount == 0 {
                allClearSummary
            } else {
                warningSummary
                ForEach(profileManager.activeProfile!.pagesWithInsecureFeeds) { page in
                    pageSection(page: page)
                }

            }
        }
        .listStyle(InsetGroupedListStyle())
        .onDisappear {
            viewModel.reset()
        }
        .navigationTitle("Security Check")
    }

    private var allClearSummary: some View {
        Section {
            Label(title: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No Issues").fontWeight(.medium)
                    Text("All feeds use secure URLs").foregroundColor(.secondary)
                }
            }, icon: {
                Image(systemName: "checkmark.shield")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }).padding(.vertical, 8)
        } header: {
            Text("Summary")
        }.modifier(SectionHeaderModifier())
    }

    private var warningSummary: some View {
        Section {
            Label(title: {
                Text("\(profileManager.activeProfile?.insecureFeedCount ?? 0) feed(s) use insecure URLs")
                    .fontWeight(.medium)
            }, icon: {
                Image(systemName: "exclamationmark.shield").foregroundColor(.orange).imageScale(.large)
            }).padding(.vertical, 8)

            Group {
                if viewModel.remediationInProgress == true {
                    HStack {
                        ProgressView().progressViewStyle(IconProgressStyle())
                        Text("Scanning…").foregroundColor(.secondary)
                    }
                } else {
                    Button {
                        viewModel.remedyInsecureUrls()
                    } label: {
                        Text("Scan for HTTPS Alternatives").buttonStyle(RegularButtonStyle())
                    }
                    .accessibilityIdentifier("remedy-button")
                }
            }.padding(.vertical, 4)

        } header: {
            Text("Summary")
        }.modifier(SectionHeaderModifier())
    }

    private func pageSection(page: Page) -> some View {
        Section {
            ForEach(page.insecureFeeds) { feed in
                HStack {
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        faviconImage: feed.feedData?.faviconImage
                    )
                    Spacer()
                    Text(feed.urlString).font(.caption).lineLimit(1).foregroundColor(.secondary)
                    if viewModel.failedRemediation.contains(feed.id) == true {
                        Image(systemName: "shield.slash").foregroundColor(.red)
                    } else {
                        Image(systemName: "lock.open").foregroundColor(.secondary)
                    }
                }.modifier(FormRowModifier())
            }
        } header: {
            Text(page.displayName).fontWeight(.light)
        }.modifier(SectionHeaderModifier())
    }
}
