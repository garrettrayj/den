//
//  OrganizerRow.swift
//  Den
//
//  Created by Garrett Johnson on 9/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct OrganizerRow: Identifiable, Hashable {
    public var id: UUID
    var page: Page
    var feed: Feed
}
