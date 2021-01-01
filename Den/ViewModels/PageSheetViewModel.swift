//
//  PageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class PageSheetViewModel: ObservableObject, Identifiable {
    enum PageSheetModal {
        case organizer, options, subscribe
    }
    
    @Published var modal: PageSheetModal
    @Published var feed: Feed?
    
    init(modal: PageSheetModal, feed: Feed? = nil) {
        self.modal = modal
        self.feed = feed
    }
}
