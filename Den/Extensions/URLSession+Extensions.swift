//
//  URLSession+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

extension URLSession {
    typealias DataTaskResult = Result<(HTTPURLResponse, Data), Error>
}
