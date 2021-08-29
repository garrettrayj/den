//
//  EditMode+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/29/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

extension EditMode {
    mutating func toggle() {
        self = self == .active ? .inactive : .active
    }
}
