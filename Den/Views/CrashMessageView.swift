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
        VStack(spacing: 16) {
            Image(systemName: "ladybug").resizable().scaledToFit().frame(width: 48, height: 48)
            Text("Application Error").font(.title)
            Text("""
                An unexpected error occurred.\n
                Close and restart to try again.
            """)
        }.modifier(SimpleMessageModifier())
    }
}
