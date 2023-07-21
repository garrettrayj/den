//
//  HashIdentifierUtility.swift
//  Den
//
//  Created by Garrett Johnson on 7/16/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

final class HashIdentifierUtility {
    static let shared = HashIdentifierUtility()
    
    let hashids = Hashids(
        salt: "",
        minHashLength: 1,
        alphabet: "♡□△☆123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    )
    
    func encode(_ value: Int64) -> String? {
        return hashids.encode(value)
    }
    
    func decode(_ value: String) -> [Int] {
        hashids.decode(value)
    }
}
