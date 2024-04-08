//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CommonStatus: View {
    @ObservedObject var profile: Profile
    
    var body: some View {
        VStack {
            if let refreshedDate = RefreshedDateStorage.getRefreshed(profile.id?.uuidString) {
                RelativeRefreshedDate(date: refreshedDate).font(.caption)
            }
        }
        .lineLimit(1)
    }
}
