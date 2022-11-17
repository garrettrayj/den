//
//  SecurityView.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SecurityView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let profile: Profile
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
        .listStyle(InsetGroupedListStyle())
        .onDisappear {
            reset()
        }
        .navigationTitle("Security")
    }

    private var allClearSummary: some View {
        Section {
            Label {
                Text("All feeds have secure URLs")
            } icon: {
                Image(systemName: "checkmark.shield").foregroundColor(.green).imageScale(.large)
            }.modifier(FormRowModifier())
        } header: {
            Text("All Clear").modifier(FormFirstHeaderModifier())
        }
    }

    private var warningSummary: some View {
        Section {
            Label {
                if insecureFeedCount == 1 {
                    Text("\(insecureFeedCount) feed has an insecure URL")
                } else {
                    Text("\(insecureFeedCount) feeds have insecure URLs")
                }
            } icon: {
                Image(systemName: "exclamationmark.shield").foregroundColor(Color(UIColor.systemOrange)).imageScale(.large)
            }.modifier(FormRowModifier())

            if remediationInProgress == true {
                Label {
                    Text("Checking…").foregroundColor(.secondary)
                } icon: {
                    ProgressView().progressViewStyle(IconProgressStyle())
                }.modifier(FormRowModifier())
            } else {
                Button {
                    remedyInsecureUrls()
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        if insecureFeedCount == 1 {
                            Text("Check for secure alternative")
                            Text("If avaialble, the feed will be updated to use the HTTPS URL")
                                .font(.caption).foregroundColor(.secondary)
                        } else {
                            Text("Check for secure alternatives")
                            Text("When available, feeds will be updated to use HTTPS URLs")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
                .modifier(FormRowModifier())
                .accessibilityIdentifier("remedy-button")
            }
        } header: {
            Text("Warning").modifier(FormFirstHeaderModifier())
        }
    }

    private func pageSection(page: Page) -> some View {
        Section {
            ForEach(page.insecureFeeds) { feed in
                HStack {
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        favicon: feed.feedData?.favicon
                    )
                    Spacer()
                    Text(feed.urlString).font(.caption).lineLimit(1).foregroundColor(.secondary)
                    if failedRemediation.contains(feed.id) == true {
                        Image(systemName: "shield.slash").foregroundColor(.red)
                    } else {
                        Image(systemName: "lock.open").foregroundColor(.secondary)
                    }
                }.modifier(FormRowModifier())
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
