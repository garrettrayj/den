//
//  ProfileViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 11/28/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Combine
import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var profile: Profile
    @Published var refreshing: Bool = false

    init(profile: Profile) {
        self.profile = profile
    }
}
