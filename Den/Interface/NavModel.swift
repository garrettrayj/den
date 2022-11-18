//
//  NavModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/18/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

class NavModel: ObservableObject {
    @Published var selection: Panel?
    @Published var path = NavigationPath()
}

