//
//  SearchModel.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

class SearchModel: ObservableObject {
    @Published var query: String = ""
}
