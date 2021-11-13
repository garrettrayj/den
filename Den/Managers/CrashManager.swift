//
//  CrashManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI
import OSLog

final class CrashManager: ObservableObject {
    @Published var showingCrashMessage = false

    public func handleCriticalError(_ anError: NSError) {
        Logger.main.critical("\(self.formatErrorMessage(anError))")
        showingCrashMessage = true
    }

    private func formatErrorMessage(_ anError: NSError?) -> String {
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
