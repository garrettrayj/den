//
//  Color+Extensions.swift
//  Den
//
//  Created by Anonymous S.I. on 04/03/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

extension Color {
    public func hexString(environment: EnvironmentValues) -> String {
        let resolvedColor = self.resolve(in: environment)

        return String(
            format: "#%02lX%02lX%02lX%02lX",
            lroundf(resolvedColor.red * 255),
            lroundf(resolvedColor.green * 255),
            lroundf(resolvedColor.blue * 255),
            lroundf(resolvedColor.opacity * 255)
        )
    }
}
