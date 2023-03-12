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

class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "Monitor")
    
    @Published private(set) var isConnected: Bool = false

    init() {
        networkMonitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
                print("NETWORK: \(path.status)")
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
