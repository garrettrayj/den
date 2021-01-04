//
//  ErrorManager.swift
//  Den
//
//  Created by Garrett Johnson on 1/3/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

/**
 Manages presentation of an unclosable alert shown in the event of unrecoverable errors.
 */
class CrashManager: ObservableObject {
    @Published var showingAlert: Bool = false
    
    public func handleCriticalError(_ anError: NSError) {
        Logger.main.critical("\(self.formatErrorMessage(anError))")
        showingAlert = true
    }
    
    private func formatErrorMessage(_ anError: NSError?) -> String {
        guard let anError = anError else { return "Unknown error" }
            
        guard anError.domain.compare("NSCocoaErrorDomain") == .orderedSame else {
            return "Application error: \(anError)"
        }
        
        var messages: String = "Unrecoverable data error. Reason(s):\n"
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
        
        for error in errors {
            if (error as? NSError)!.userInfo.keys.contains("conflictList") {
                messages =  messages + "Generic merge conflict. see details : \(error)"
            } else {
                let entityName = ((error as? NSError)!.userInfo["NSValidationErrorObject"] as! NSManagedObject).entity.name ?? "Unknown Entity"
                let attributeName = "\((error as? NSError)!.userInfo["NSValidationErrorKey"] ?? "Unknown Attribute")"
                var message = ""
                
                switch (error.code) {
                case NSManagedObjectValidationError:
                    message = "Generic validation error.";
                    break;
                case NSValidationMissingMandatoryPropertyError:
                    message = String(format:"The attribute '%@' mustn't be empty.", attributeName)
                    break;
                case NSValidationRelationshipLacksMinimumCountError:
                    message = String(format:"The relationship '%@' doesn't have enough entries.", attributeName)
                    break;
                case NSValidationRelationshipExceedsMaximumCountError:
                    message = String(format:"The relationship '%@' has too many entries.", attributeName)
                    break;
                case NSValidationRelationshipDeniedDeleteError:
                    message = String(format:"To delete, the relationship '%@' must be empty.", attributeName)
                    break;
                case NSValidationNumberTooLargeError:
                    message = String(format:"The number of the attribute '%@' is too large.", attributeName)
                    break;
                case NSValidationNumberTooSmallError:
                    message = String(format:"The number of the attribute '%@' is too small.", attributeName)
                    break;
                case NSValidationDateTooLateError:
                    message = String(format:"The date of the attribute '%@' is too late.", attributeName)
                    break;
                case NSValidationDateTooSoonError:
                    message = String(format:"The date of the attribute '%@' is too soon.", attributeName)
                    break;
                case NSValidationInvalidDateError:
                    message = String(format:"The date of the attribute '%@' is invalid.", attributeName)
                    break;
                case NSValidationStringTooLongError:
                    message = String(format:"The text of the attribute '%@' is too long.", attributeName)
                    break;
                case NSValidationStringTooShortError:
                    message = String(format:"The text of the attribute '%@' is too short.", attributeName)
                    break;
                case NSValidationStringPatternMatchingError:
                    message = String(format:"The text of the attribute '%@' doesn't match the required pattern.", attributeName)
                    break;
                default:
                    message = String(format:"Unknown error (code %i).", error.code) as String
                    break;
                }

                messages = messages + "\(entityName).\(attributeName): \(message)\n"
            }
        }
        
        return messages
    }
}
