//
//  WebViewError.swift
//  Den
//
//  Created by Garrett Johnson on 3/18/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

struct WebViewError {
    var error: Error
    
    var html: String {
        """
        <html>
        <head>
        <title>Error</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no, user-scalable=no" />
        <style>
        :root {
            color-scheme: light dark;
        }
        body {
            display: flex;
            font: -apple-system-body;
            justify-content: center;
            padding: 16px;
        }
        div {
            align-self: center;
            max-width: 600px;
            text-align: center;
        }
        h1 {
            margin: 0 0 12px;
        }
        p {
            margin: 0;
        }
        </style>
        </head>
        <body>
        <div>
        <h1>⚠️</h1>
        <p>
        \(error.localizedDescription)
        </p>
        </div>
        </body>
        </html>
        """
    }
}
