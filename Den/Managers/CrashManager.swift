//
//  CrashController.swift
//  Den
//
//  Created by Garrett Johnson on 1/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import OSLog
import CoreData

class CrashManager: ObservableObject {
    var mainViewModel: MainViewModel

    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    public func handleCriticalError(_ anError: NSError) {
        Logger.main.critical("\(self.formatErrorMessage(anError))")
        
        mainViewModel.pageSheetMode = .crashMessage
        mainViewModel.showingPageSheet = true
    }
    
    private func formatErrorMessage(_ anError: NSError?) -> String {
        guard let anError = anError else { return "Unknown error" }
            
        guard anError.domain.compare("NSCocoaErrorDomain") == .orderedSame else {
            return "Application error: \(anError)"
        }
        
        let messages: String = "Unrecoverable data error. \(anError.localizedDescription)"
        var errors = [AnyObject]()
        
        if anError.code == NSValidationMultipleErrorsError {
            errors = anError.userInfo[NSDetailedErrorsKey] as! [AnyObject]
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
