//
//  CrashManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI

struct CrashManager {
    static func handleCriticalError(_ anError: NSError) {
        let formatted = self.formatErrorMessage(anError)
        Logger.main.critical("\(formatted)")
        NotificationCenter.default.post(name: .showCrashMessage, object: nil)
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
