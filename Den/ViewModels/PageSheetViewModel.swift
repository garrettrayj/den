//
//  PageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class PageSheetViewModel {
    enum PageSheetState {
        case organizer, options, subscribe
    }
    
    var state: PageSheetState
    var feed: Feed?
    
    init(state: PageSheetState, feed: Feed? = nil) {
        self.state = state
        self.feed = feed
    }
}

// MARK: - <Hashable>

extension PageSheetViewModel: Hashable {

    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self).hashValue)
    }

    // `hashValue` is deprecated starting Swift 4.2, but if you use
    // earlier versions, then just override `hashValue`.
    //
    // public var hashValue: Int {
    //    return ObjectIdentifier(self).hashValue
    // }
}

// MARK: - <Equatable>

extension PageSheetViewModel: Equatable {

    public static func ==(lhs: PageSheetViewModel, rhs: PageSheetViewModel) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}


// MARK: - <Identifiable>

extension PageSheetViewModel: Identifiable {
}
