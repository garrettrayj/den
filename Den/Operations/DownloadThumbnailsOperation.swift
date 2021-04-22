//
//  DownloadThumbnailsOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog


class DownloadThumbnailsOperation: Operation {
    var inputWorkingItems: [WorkingFeedItem] = []
    var outputWorkingItems: [WorkingFeedItem] = []
    
    private var queue = OperationQueue()

    override func main() {
        var combinedThumbnailOperations: [Operation] = []
        var saveOperations: [SaveThumbnailOperation] = []
        
        for item in inputWorkingItems {
            let thumbnailDataOperation = DataTaskOperation(item.image)
            let saveThumbnailOperation = SaveThumbnailOperation()
            saveOperations.append(saveThumbnailOperation)
            
            let thumbnailDataAdapter = BlockOperation() { [unowned saveThumbnailOperation, unowned thumbnailDataOperation] in
                saveThumbnailOperation.thumbnailData = thumbnailDataOperation.data
                saveThumbnailOperation.thumbnailResponse = thumbnailDataOperation.response
                saveThumbnailOperation.workingFeedItem = item
            }
            
            thumbnailDataAdapter.addDependency(thumbnailDataOperation)
            saveThumbnailOperation.addDependency(thumbnailDataAdapter)

            combinedThumbnailOperations.append(thumbnailDataOperation)
            combinedThumbnailOperations.append(thumbnailDataAdapter)
            combinedThumbnailOperations.append(saveThumbnailOperation)
        }
        
        self.queue.addOperations(combinedThumbnailOperations, waitUntilFinished: true)
        
        for operation in saveOperations {
            if let workingFeedItem = operation.workingFeedItem {
                outputWorkingItems.append(workingFeedItem)
            }
        }
    }
}
