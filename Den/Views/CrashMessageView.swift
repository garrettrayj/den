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
            Text("Application Crashed").font(.title)
            Text("""
                A critical error occurred.
                Fully close Den then restart to try again.
                Please consider sending a bug report if you see this repeatedly.
            """)
            .foregroundColor(Color(.secondaryLabel))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }
}
