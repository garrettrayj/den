//
//  NavigationStore.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

final class NavigationStore: ObservableObject {
    @Published var path = NavigationPath()

    func encoded() -> Data? {
        let encoder = JSONEncoder()
        return try? path.codable.map(encoder.encode)
    }

    func restore(from data: Data, context: NSManagedObjectContext) {
        let decoder = JSONDecoder()
        decoder.userInfo[CodingUserInfoKey.managedObjectContext] = context
        
        do {
            let codable = try decoder.decode(NavigationPath.CodableRepresentation.self, from: data)
            path = NavigationPath(codable)
        } catch {
            path = NavigationPath()
        }
    }
}
