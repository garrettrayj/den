//
//  SecurityCheckViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/24/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class SecurityCheckViewModel: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager
    let profileManager: ProfileManager
    let queue = OperationQueue()

    @Published var remediationInProgress: Bool = false
    @Published var failedRemediation: [UUID?] = []

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profileManager: ProfileManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager

        self.queue.maxConcurrentOperationCount = 6
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
