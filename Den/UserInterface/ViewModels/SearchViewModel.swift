//
//  SearchViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 1/20/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

final class SearchViewModel: ObservableObject {
    @Published var query: String = ""

    var isEmpty: Bool {
        query == ""
    }
}
