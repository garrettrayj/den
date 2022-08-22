//
//  XCUIElement+Extensions.swift
//  DenScreenshots
//
//  Created by Garrett Johnson on 2/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    func forceTap() {
        let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
        coordinate.tap()
    }
}
