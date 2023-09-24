//
//  CrashUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct CrashUtility {
    static func handleCriticalError(_ anError: NSError) {
        let formattedMessage = self.formatErrorMessage(anError)
        Logger.main.critical("\(formattedMessage)")
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .appErrored,
                object: nil,
                userInfo: ["message": formattedMessage as Any]
            )
        }
    }

    static func formatErrorMessage(_ anError: NSError?) -> String {
        guard let anError = anError else { return "Unknown error" }

        guard anError.domain.compare("NSCocoaErrorDomain") == .orderedSame else {
            return "Application error: \(anError)"
        }

        let messages: String = "Unrecoverable data error. \(anError.localizedDescription)"
        var errors = [AnyObject]()

        if anError.code == NSValidationMultipleErrorsError {
            if let multipleErros = anError.userInfo[NSDetailedErrorsKey] as? [AnyObject] {
                errors = multipleErros
            }
        } else {
            errors = [AnyObject]()
            errors.append(anError)
        }

        if errors.count == 0 {
            return ""
        }

        return messages
    }
}
