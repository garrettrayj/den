//
//  NetworkMonitor.swift
//  Den
//
//  Created by Garrett Johnson on 3/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected: Bool = false
    
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")

    init() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
