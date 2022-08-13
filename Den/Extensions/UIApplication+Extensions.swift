//
//  UIApplication+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/12/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func openOptional(_ url: URL?) {
        if let url = url {
            open(url)
        }
    }

    func openAddress(_ address: String) {
        if let url = URL(string: address) {
            open(url)
        }
    }
}
