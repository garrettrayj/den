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
class DenHosting {
    static var controller: UIViewController?
    static var nextModalPresentationStyle: UIModalPresentationStyle?

    static func openSafari(url:URL,tint:UIColor? = nil) {
        guard let controller = controller else {
            preconditionFailure("No controller present. Did you remember to use DenHostingController instead of UIHostingController in your SceneDelegate?")
        }

        let vc = SFSafariViewController(url: url)
        vc.preferredBarTintColor = tint
        //vc.delegate = self

        controller.present(vc, animated: true)
    }
}

/**
 Enables controlling the presentation style of modals.
 */
class DenHostingController<Content> : UIHostingController<Content> where Content : View {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        DenHosting.controller = self
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let nextStyle = DenHosting.nextModalPresentationStyle {
            viewControllerToPresent.modalPresentationStyle = nextStyle
            DenHosting.nextModalPresentationStyle = nil
        }

        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
}
