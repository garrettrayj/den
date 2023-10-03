//
//  SafariView.swift
//  Den
//
//  Created by Garrett Johnson on 10/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

#if os(iOS)
import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.userTint) private var userTint

    let url: URL
    let readerMode: Bool?

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<SafariView>
    ) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = readerMode ?? false
        config.barCollapsingEnabled = false

        let safariViewController = SFSafariViewController(url: url, configuration: config)
        safariViewController.delegate = context.coordinator
        safariViewController.preferredBarTintColor = .systemBackground

        if let userTint = userTint {
            safariViewController.preferredControlTintColor = UIColor(userTint)
        }

        return safariViewController
    }

    func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<SafariView>
    ) { }

    class Coordinator: NSObject, SFSafariViewControllerDelegate {
        let dismiss: DismissAction

        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }

        func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            dismiss()
        }
    }
}
#endif
