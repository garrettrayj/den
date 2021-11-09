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

    var contentViewModel: ContentViewModel

    private var viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext, contentViewModel: ContentViewModel) {
        self.viewContext = viewContext
        self.contentViewModel = contentViewModel

        self.queue.maxConcurrentOperationCount = 10
    }

    func reset() {
        queue.cancelAllOperations()
        remediationInProgress = false
        failedRemediation = []
    }

    func remedyInsecureUrls() {
        guard let activeProfile = contentViewModel.activeProfile else { return }

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
                        self.contentViewModel.handleCriticalError(error as NSError)
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
