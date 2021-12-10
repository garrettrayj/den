//
//  SecurityCheckView.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SecurityCheckView: View {
    @EnvironmentObject var profileManager: ProfileManager

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
        Section(header: Text("Summary").modifier(SectionHeaderModifier())) {
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
        Section(header: Text("Summary").modifier(SectionHeaderModifier())) {
            Label(title: {
                VStack(alignment: .leading, spacing: 4) {
                    if profileManager.activeProfile?.insecureFeedCount ?? 0 > 0 {
                        Text("\(profileManager.activeProfile?.insecureFeedCount ?? 0) subscriptions have insecure URLs")
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
                        ProgressView().progressViewStyle(IconProgressStyle())
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func pageSection(page: Page) -> some View {
        Section(header: Text(page.displayName).modifier(SectionHeaderModifier())) {
            ForEach(page.insecureFeeds) { feed in
                HStack {
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        faviconImage: feed.feedData?.faviconImage
                    )
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
                }.modifier(FormRowModifier())
            }
        }
    }
}
