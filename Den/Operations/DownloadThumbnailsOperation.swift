//
//  DownloadThumbnailsOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class DownloadThumbnailsOperation: Operation {
    var inputWorkingItems: [WorkingItem] = []
    var outputWorkingItems: [WorkingItem] = []

    var queue = OperationQueue()

    override init() {
        super.init()
        queue.maxConcurrentOperationCount = 1
    }

    override func main() {
        var combinedOps: [Operation] = []
        var saveOps: [SaveThumbnailOperation] = []

        for item in inputWorkingItems {
            guard let url = item.image else {
                outputWorkingItems.append(item)
                continue
            }

            let dataOp = DataTaskOperation(url)
            let saveOp = SaveThumbnailOperation()
            saveOps.append(saveOp)

            let thumbnailDataAdapter = BlockOperation { [unowned saveOp, unowned dataOp] in
                saveOp.thumbnailData = dataOp.data
                saveOp.thumbnailResponse = dataOp.response
                saveOp.workingFeedItem = item
            }

            thumbnailDataAdapter.addDependency(dataOp)
            saveOp.addDependency(thumbnailDataAdapter)

            combinedOps.append(dataOp)
            combinedOps.append(thumbnailDataAdapter)
            combinedOps.append(saveOp)
        }

        queue.addOperations(combinedOps, waitUntilFinished: true)
        for operation in saveOps {
            if let workingFeedItem = operation.workingFeedItem {
                outputWorkingItems.append(workingFeedItem)
            }
        }
    }
}
