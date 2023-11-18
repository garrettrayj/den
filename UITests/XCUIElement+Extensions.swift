//
//  XCUIElement+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 7/17/23.
//  Copyright © 2023 Garrett Johnson
//

import XCTest

extension XCUIElement {
    func forceTap() {
        #if os(macOS)
        self.tap()
        #else
        if self.isHittable {
            self.tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(
                withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0)
            )
            coordinate.tap()
        }
        #endif
    }
    
    func waitUntilAvailable(_ test: UITestCase) -> XCUIElement {
        test.expectation(
            for: NSPredicate(format: "exists == 1 AND hittable == 1"),
            evaluatedWith: self,
            handler: nil
        )
        test.waitForExpectations(timeout: 10, handler: nil)
        
        return self
    }
}
