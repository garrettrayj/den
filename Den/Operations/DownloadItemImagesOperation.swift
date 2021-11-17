//
//  DownloadItemImagesOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class DownloadItemImagesOperation: Operation {
    var inputWorkingItems: [WorkingItem] = []
    var outputWorkingItems: [WorkingItem] = []

    var queue = OperationQueue()

    private var itemLimit: Int

    init(itemLimit: Int) {
        self.itemLimit = itemLimit

        queue.maxConcurrentOperationCount = 1
    }

    override func main() {
        var combinedOps: [Operation] = []
        var saveOps: [SaveItemImageOperation] = []

        for (idx, item) in inputWorkingItems.enumerated() {
            guard let url = item.image else {
                outputWorkingItems.append(item)
                continue
            }

            if idx + 1 > itemLimit {
                outputWorkingItems.append(item)
                continue
            }

            let dataOp = DataTaskOperation(url)
            let saveOp = SaveItemImageOperation()
            saveOps.append(saveOp)

            let imageDataAdapter = BlockOperation { [unowned saveOp, unowned dataOp] in
                saveOp.data = dataOp.data
                saveOp.httpResponse = dataOp.response
                saveOp.workingItem = item
            }

            imageDataAdapter.addDependency(dataOp)
            saveOp.addDependency(imageDataAdapter)

            combinedOps.append(dataOp)
            combinedOps.append(imageDataAdapter)
            combinedOps.append(saveOp)
        }

        queue.addOperations(combinedOps, waitUntilFinished: true)
        for operation in saveOps {
            if let workingFeedItem = operation.workingItem {
                outputWorkingItems.append(workingFeedItem)
            }
        }
    }
}
