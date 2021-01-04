//
//  SafariManager.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI
import SafariServices

/**
 Class for providing functionality not quite reachable with SwiftUI
 (such as opening SFSafariViewController full screen)
 */
class SafariManager: ObservableObject {
    public var controller: UIViewController?
    public var nextModalPresentationStyle: UIModalPresentationStyle?

    func openSafari(url:URL, readerMode: Bool = false) {
        guard let controller = controller else {
            preconditionFailure("No controller present.")
        }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode
        
        let vc = SFSafariViewController(url: url, configuration: config)
        
        if let nextStyle = nextModalPresentationStyle {
            controller.modalPresentationStyle = nextStyle
            nextModalPresentationStyle = nil
        }
        
        controller.present(vc, animated: true)
    }
}
