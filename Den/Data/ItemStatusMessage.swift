//
//  ItemStatusMessage.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

struct ItemStatusMessage {
    let read: Bool
    let feedObjectID: NSManagedObjectID?
    let pageObjectID: NSManagedObjectID?
    let profileObjectID: NSManagedObjectID?
}
