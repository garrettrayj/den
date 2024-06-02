//
//  Acknowledgements.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Acknowledgements: View {
    @State private var html: String?
    
    var body: some View {
        VStack {
            if let html {
                HTMLWebView(htmlContent: html)
            }
        }
        .task {
            guard
                let url = Bundle.main.url(forResource: "Acknowledgements", withExtension: "html"),
                let raw = try? String(contentsOf: url, encoding: .utf8)
            else {
                return
            }
            
            html = raw.replacingOccurrences(
                of: "</head>",
                with: """
                <style>
                :root { color-scheme: light dark; }
                body { font: -apple-system-body; margin: 0 20px 20px 20px; }
                </style>
                </head>
                """
            )
        }
        .toolbarTitleDisplayMode(.inline)
    }
}
