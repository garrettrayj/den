//
//  SecurityCheckViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/24/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class SecurityCheckViewModel: ObservableObject {
    @Published var remediationInProgress: Bool = false
    @Published var failedRemediation: [UUID?] = []

    let queue = OperationQueue()

    private var viewContext: NSManagedObjectContext
    private var profileManager: ProfileManager
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, profileManager: ProfileManager, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.profileManager = profileManager
        self.crashManager = crashManager

        self.queue.maxConcurrentOperationCount = 10
    }

    func reset() {
        queue.cancelAllOperations()
        remediationInProgress = false
        failedRemediation = []
    }

    func remedyInsecureUrls() {
        var operations: [Operation] = []
        profileManager.activeProfile!.insecureFeeds.forEach { feed in
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
                self.failedRemediation.append(feed.id)
            }
        }

        fetchCheckAdapter.addDependency(fetchOp)
        checkOp.addDependency(fetchCheckAdapter)
        completionOp.addDependency(checkOp)

        return [fetchOp, checkOp, fetchCheckAdapter, completionOp]
    }
}
