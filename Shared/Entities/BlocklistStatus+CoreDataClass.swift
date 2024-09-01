//
//  BlocklistStatus+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 10/17/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

@objc(BlocklistStatus)
final public class BlocklistStatus: NSManagedObject {
    static func create(
        in managedObjectContext: NSManagedObjectContext,
        blocklist: Blocklist
    ) -> BlocklistStatus {
        let blocklistStatus = self.init(context: managedObjectContext)
        blocklistStatus.id = UUID()
        blocklistStatus.blocklistId = blocklist.id

        return blocklistStatus
    }
}
