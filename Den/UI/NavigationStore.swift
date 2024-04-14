//
//  NavigationStore.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

@MainActor 
final class NavigationStore: ObservableObject {
    @Published var path = NavigationPath()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func encoded() -> Data? {
        try? path.codable.map(encoder.encode)
    }

    func restore(from data: Data) {
        do {
            let codable = try decoder.decode(
                NavigationPath.CodableRepresentation.self, from: data
            )
            path = NavigationPath(codable)
        } catch {
            path = NavigationPath()
        }
    }
}
