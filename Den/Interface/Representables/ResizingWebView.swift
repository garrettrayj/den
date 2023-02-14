//
//  ResizingWebView.swift
//  Den
//
//  Created by Garrett Johnson on 1/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Combine
import WebKit

/// Override and extend WKWebView with an `intrinsicContentSize` that matches scrollview
/// using automatic size invalidation on an interval.
/// While most resize bubbling needs should be covered by other calls to `invalidateIntrinsicContentSize()`,
/// scheduled invalidation handles edge cases such as JavaScript, e.g. Twitter widgets, adjusting content
/// size unpredictably.
class ResizingWebView: WKWebView {
    var cancellable: Cancellable?

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)

        cancellable = DispatchQueue.main.schedule(
            after: .init(.now() + 0.5),
            interval: 1
        ) {
            self.invalidateIntrinsicContentSize()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return self.scrollView.contentSize
    }

    deinit {
        cancellable?.cancel()
    }
}
