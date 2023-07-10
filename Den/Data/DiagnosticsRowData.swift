//
//  DiagnosticsRowData.swift
//  Den
//
//  Created by Garrett Johnson on 7/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/// Flattened, sort friendly, feed representation for reports.
public struct DiagnosticsRowData: Identifiable, Equatable {
    public var entity: Feed
    public var id: String
    public var title: String
    public var page: String
    public var address: String
    public var isSecure: Int
    public var format: String
    public var httpStatus: String
    public var responseTime: Int
    public var server: String
    public var cacheControl: String
    public var age: String
    public var eTag: String
}
