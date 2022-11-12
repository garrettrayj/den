//
//  CustomEnvironment.swift
//  Den
//
//  Created by Garrett Johnson on 10/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

private struct PersistentContainerKey: EnvironmentKey {
    static let defaultValue: NSPersistentContainer? = nil
}

extension EnvironmentValues {
  var persistentContainer: NSPersistentContainer? {
    get { self[PersistentContainerKey.self] }
    set { self[PersistentContainerKey.self] = newValue }
  }
}
