//
//  SecurityCheckView.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SecurityCheckView: View {
    @ObservedObject var viewModel: SecurityCheckViewModel

    var body: some View {
        List {
            if viewModel.contentViewModel.activeProfile?.insecureFeedCount == 0 {
                allClearSummary
            } else {
                warningSummary
                ForEach(viewModel.contentViewModel.activeProfile!.pagesWithInsecureFeeds) { page in
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
        Section(header: Text("Summary")) {
            Label(title: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No Issues").fontWeight(.medium)
                    Text("All subscriptions have secure URLs").foregroundColor(.secondary)
                }
            }, icon: {
                Image(systemName: "checkmark.shield")
                    .imageScale(.large)
                    .foregroundColor(.green)
            }).padding(.vertical, 8)
        }
    }

    private var warningSummary: some View {
        Section(header: Text("Summary")) {
            Label(title: {
                VStack(alignment: .leading, spacing: 4) {
                    if viewModel.contentViewModel.activeProfile?.insecureFeedCount ?? 0 > 0 {
                        Text("\(viewModel.contentViewModel.activeProfile?.insecureFeedCount ?? 0) subscriptions have insecure URLs")
                            .fontWeight(.medium)
                        Text("Den can look for secure alternatives to use instead").foregroundColor(.secondary)
                    } else {
                        Text("One subscription with an insecure URL").fontWeight(.medium)
                        Text("Den can look for a secure alternative to use instead").foregroundColor(.secondary)
                    }
                }
            }, icon: {
                Image(systemName: "exclamationmark.shield")
                    .imageScale(.large)
                    .foregroundColor(.orange)
            }).padding(.vertical, 8)

            Button {
                viewModel.remedyInsecureUrls()
            } label: {
                HStack {
                    Text("Remedy Insecure URLs")
                    Spacer()
                    if viewModel.remediationInProgress == true {
                        ActivityRep()
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func pageSection(page: Page) -> some View {
        Section(header: Text(page.displayName)) {
            ForEach(page.insecureFeeds) { feed in
                HStack {
                    FeedTitleLabelView(feed: feed).padding(.vertical, 4)
                    Spacer()

                    HStack(spacing: 4) {
                        Image(systemName: "lock.open")
                        Text(feed.urlString)
                    }
                    .font(.caption)
                    .lineLimit(1)
                    .foregroundColor(.secondary)

                    if viewModel.failedRemediation.contains(feed.id) == true {
                        Image(systemName: "shield.slash").foregroundColor(.red)
                    }

                }
            }
        }
    }
}
