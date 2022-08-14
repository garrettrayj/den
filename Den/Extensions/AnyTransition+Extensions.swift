//
//  AnyTransition+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

extension AnyTransition {
    static var moveTopAndFade: AnyTransition {
        AnyTransition.move(edge: .top).combined(with: .fade)
    }
}
