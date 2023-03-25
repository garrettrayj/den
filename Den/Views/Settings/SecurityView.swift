//
//  SecurityView.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SecurityView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    let queue = OperationQueue()

    @State private var remediationInProgress: Bool = false
    @State private var failedRemediation: [UUID?] = []

    var insecureFeedCount: Int {
        profile.insecureFeedCount
    }

    var body: some View {
        List {
            if insecureFeedCount == 0 {
                allClearSummary
            } else {
                warningSummary
                ForEach(profile.pagesWithInsecureFeeds) { page in
                    pageSection(page: page)
                }

            }
        }
        .onDisappear {
            reset()
        }
        .navigationTitle("Security")
    }

    private var allClearSummary: some View {
        Section {
            Text("All feeds have secure web addresses.").modifier(FormRowModifier())
        } header: {
            Label {
                Text("No Problems")
            } icon: {
                Image(systemName: "checkmark.shield")
            }.modifier(FirstFormHeaderModifier())
        }
    }

    private var warningSummary: some View {
        Section {
            if remediationInProgress == true {
                Label {
                    Text("Checking…").foregroundColor(Color(.secondaryLabel)).modifier(FormRowModifier())
                } icon: {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            } else {
                Button {
                    remedyInsecureUrls()
                } label: {
                    Label {
                        Group {
                            if insecureFeedCount == 1 {
                                Text("Check for a secure option")
                            } else {
                                Text("Check for secure options")
                            }
                        }.modifier(FormRowModifier())
                    } icon: {
                        Image(systemName: "bolt.shield")
                    }
                }
                .accessibilityIdentifier("security-remedy-button")
            }
        } header: {
            Label {
                if insecureFeedCount == 1 {
                    Text("\(insecureFeedCount) feed is using an insecure web address.")
                } else {
                    Text("\(insecureFeedCount) feeds use insecure web addresses.")
                }
            } icon: {
                Image(systemName: "exclamationmark.shield")
            }
            .modifier(FirstFormHeaderModifier())
        } footer: {
            Text("Feeds will be updated to use HTTPS when available.")
        }
    }

    private func pageSection(page: Page) -> some View {
        Section {
            ForEach(page.insecureFeeds) { feed in
                HStack {
                    FeedTitleLabel(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    ).modifier(FormRowModifier())
                    Spacer()
                    Text(feed.urlString).font(.caption).lineLimit(1).foregroundColor(Color(.secondaryLabel))
                    if failedRemediation.contains(feed.id) == true {
                        Image(systemName: "shield.slash").foregroundColor(Color(.systemRed))
                    } else {
                        Image(systemName: "lock.open").foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
        } header: {
            Text(page.displayName)
        }
    }

    private func reset() {
        queue.cancelAllOperations()
        remediationInProgress = false
        failedRemediation = []
    }

    private func remedyInsecureUrls() {
        var operations: [Operation] = []

        profile.insecureFeeds.forEach { feed in
            operations.append(contentsOf: createRemedyOps(feed: feed))
        }

        remediationInProgress = true
        DispatchQueue.global(qos: .userInitiated).async {
            self.queue.addOperations(operations, waitUntilFinished: true)
            DispatchQueue.main.async {
                self.remediationInProgress = false
                if self.viewContext.hasChanges {
                    do {
                        try self.viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }

    private func createRemedyOps(feed: Feed) -> [Operation] {
        guard let feedUrl = feed.url else { return [] }
        var components = URLComponents(url: feedUrl, resolvingAgainstBaseURL: true)
        components?.scheme = "https"
        guard let secureUrl = components?.url else { return [] }

        let fetchOp = DataTaskOperation(secureUrl)
        let checkOp = FeedCheckOperation()
        let fetchCheckAdapter = BlockOperation { [unowned fetchOp, unowned checkOp] in
            checkOp.httpResponse = fetchOp.response
            checkOp.httpTransportError = fetchOp.error
            checkOp.data = fetchOp.data
        }
        let completionOp = BlockOperation { [unowned checkOp] in
            if checkOp.feedIsValid {
                feed.url = secureUrl
            } else {
                DispatchQueue.main.async {
                    self.failedRemediation.append(feed.id)
                }
            }
        }

        fetchCheckAdapter.addDependency(fetchOp)
        checkOp.addDependency(fetchCheckAdapter)
        completionOp.addDependency(checkOp)

        return [fetchOp, checkOp, fetchCheckAdapter, completionOp]
    }
}
