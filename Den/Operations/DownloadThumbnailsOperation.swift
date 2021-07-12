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

    private var queue = OperationQueue()

    override func main() {
        var combinedOps: [Operation] = []
        var saveOps: [SaveThumbnailOperation] = []

        for item in inputWorkingItems {
            let dataOp = DataTaskOperation(item.image)
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

        self.queue.addOperations(combinedOps, waitUntilFinished: true)

        for operation in saveOps {
            if let workingFeedItem = operation.workingFeedItem {
                outputWorkingItems.append(workingFeedItem)
            }
        }
    }
}
