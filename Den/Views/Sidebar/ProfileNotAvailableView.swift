//
//  ProfileNotAvailableView.swift
//  Den
//
//  Created by Garrett Johnson on 2/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfileNotAvailableView: View {
    var body: some View {
        StatusBoxView(
            message: Text("Profile Not Available"),
            symbol: "hexagon"
        )
        .navigationTitle("")
    }
}
