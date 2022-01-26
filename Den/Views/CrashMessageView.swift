//
//  CrashMessageView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct CrashMessageView: View {
    var body: some View {
        StatusBoxView(message: Text("Application Error"), symbol: "ladybug")
    }
}
