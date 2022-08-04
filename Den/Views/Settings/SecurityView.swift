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
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var profileManager: ProfileManager

    let queue = OperationQueue()

    @State var remediationInProgress: Bool = false
    @State var failedRemediation: [UUID?] = []

    var insecureFeedCount: Int {
        profileManager.activeProfile?.insecureFeedCount ?? 0
    }

    var body: some View {
        List {
            if insecureFeedCount == 0 {
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
            reset()
        }
        .navigationTitle("Security")
        .modifier(BackNavigationModifier(title: "Settings"))
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
                Text("\(insecureFeedCount) insecure URL\(insecureFeedCount > 1 ? "s" : "")")
                    .fontWeight(.medium)
            }, icon: {
                Image(systemName: "exclamationmark.shield").foregroundColor(.orange).imageScale(.large)
            }).padding(.vertical, 8)

            Group {
                if remediationInProgress == true {
                    HStack {
                        ProgressView().progressViewStyle(IconProgressStyle())
                        Text("Scanning…").foregroundColor(.secondary)
                    }
                } else {
                    Button {
                        remedyInsecureUrls()
                    } label: {
                        Text("Scan for HTTPS Alternatives")
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
            Label(page.displayName, systemImage: page.wrappedSymbol)
                #if targetEnvironment(macCatalyst)
                .font(.headline)
                #endif
        }.modifier(SectionHeaderModifier())
    }

    func reset() {
        queue.cancelAllOperations()
        remediationInProgress = false
        failedRemediation = []
    }

    func remedyInsecureUrls() {
        guard let activeProfile = profileManager.activeProfile else { return }

        var operations: [Operation] = []

        activeProfile.insecureFeeds.forEach { feed in
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
                        self.crashManager.handleCriticalError(error as NSError)
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
