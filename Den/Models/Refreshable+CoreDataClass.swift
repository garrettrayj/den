//
//  Refreshable+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Refreshable)
public class Refreshable: NSManagedObject {
    public var feedsArray: [Feed] {
        preconditionFailure("This property must be overridden")
    }
    
    func onRefreshComplete() {
        preconditionFailure("This method must be overridden")
    }
}
