//
//  DenHosting.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import SafariServices

/**
 Static class for providing functionality not quite reachable with SwiftUI (such as opening SFSafariViewController full screen)
 */
class SafariPresenter {
    static let shared = SafariPresenter()
    
    static var controller: UIViewController?
    static var nextModalPresentationStyle: UIModalPresentationStyle?

    static func openSafari(url:URL, readerMode: Bool = false) {
        guard let controller = controller else {
            preconditionFailure("No controller present.")
        }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode
        
        let vc = SFSafariViewController(url: url, configuration: config)
        
        if let nextStyle = SafariPresenter.nextModalPresentationStyle {
            controller.modalPresentationStyle = nextStyle
            SafariPresenter.nextModalPresentationStyle = nil
        }
        
        controller.present(vc, animated: true)
    }
}
