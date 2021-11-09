//
//  SubscribeViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class SubscribeViewModel: ObservableObject {
    @Published var destinationPageId: String?
    @Published var urlText: String = ""
    @Published var urlIsValid: Bool?
    @Published var validationAttempts: Int = 0
    @Published var validationMessage: String?
    @Published var loading: Bool = false

    private var viewContext: NSManagedObjectContext
    private var contentViewModel: ContentViewModel

    var destinationPage: Page? {
        guard let activeProfile = contentViewModel.activeProfile else { return nil }

        if
            let destinationPageId = destinationPageId,
            let destinationPage = activeProfile.pagesArray.first(where: { page in
                page.id != nil && page.id?.uuidString == destinationPageId
            }) {
            return destinationPage
        }

        return nil
    }

    init(
        viewContext: NSManagedObjectContext,
        contentViewModel: ContentViewModel
    ) {
        self.viewContext = viewContext
        self.contentViewModel = contentViewModel

        self.urlText = contentViewModel.openedUrlString
        self.destinationPageId = contentViewModel.currentPageId
    }

    func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        withAnimation(.default) { validationAttempts += 1 }
    }

    func validateUrl() {
        validationMessage = nil
        urlIsValid = nil

        if urlText == "" {
            self.failValidation(message: "URL cannot be blank")
            return
        }

        if self.urlText.contains(" ") {
            self.failValidation(message: "URL cannot contain spaces")
            return
        }

        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "URL must begin with \"http://\" or \"https://\"")
            return
        }

        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse URL")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "URL is unopenable")
            return
        }

        urlIsValid = true
    }

    func addSubscription(callback: @escaping () -> Void) {
        guard
            let url = URL(string: urlText),
            let destinationPage = destinationPage
        else { return }

        self.loading = true
        let feed = Feed.create(in: self.viewContext, page: destinationPage, url: url, prepend: true)
        contentViewModel.refresh(feed: feed) { _ in
            self.contentViewModel.resetSubscribe()
            self.loading = false
            callback()
        }
    }
}
