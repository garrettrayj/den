//
//  FeedURLResponse.swift
//  Den
//
//  Created by Garrett Johnson on 7/9/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import Foundation

struct FeedURLResponse {
    var responseTime: Float = 0
    var statusCode: Int16 = 0
    var server: String?
    var cacheControl: String?
    var age: String?
    var eTag: String?
}
