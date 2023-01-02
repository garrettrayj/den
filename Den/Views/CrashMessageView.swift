//
//  CrashMessageView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

struct CrashMessageView: View {
    var body: some View {
        StatusBoxView(
            message: Text("Critical Error"),
            caption: Text("Restart to try again"),
            symbol: "xmark.octagon"
        ).background(Color(UIColor.systemBackground))
    }
}
