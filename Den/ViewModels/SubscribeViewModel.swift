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
    @Published var page: Page?
    @Published var urlText: String = ""
    @Published var urlIsValid: Bool?
    @Published var validationAttempts: Int = 0
    @Published var validationMessage: String?
    @Published var loading: Bool = false

    var newFeed: Feed?

    private var viewContext: NSManagedObjectContext
    private var profileManager: ProfileManager
    private var refreshManager: RefreshManager

    var targetPage: Page? {
        guard let profile = profileManager.activeProfile else { return nil }

        // Use the currently active page if available
        if let page = page {
            return page
        }

        // Fallback to the first page in profile
        if let page = profile.pagesArray.first {
            return page
        }

        // No destination, user will see prompt to create a page
        return nil
    }

    init(
        viewContext: NSManagedObjectContext,
        profileManager: ProfileManager,
        refreshManager: RefreshManager,
        urlText: String,
        page: Page?
    ) {
        self.viewContext = viewContext
        self.profileManager = profileManager
        self.refreshManager = refreshManager

        self.urlText = urlText
        self.page = page
    }

    func validateUrl() {
        validationMessage = nil
        urlIsValid = nil

        if urlText == "" {
            self.failValidation(message: "Address may not be blank")
            return
        }

        if self.urlText.contains(" ") {
            self.failValidation(message: "Address may not contain spaces")
            return
        }

        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "Address must begin with “http://” or “https://”")
            return
        }

        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse URL")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "Unopenable URL")
            return
        }

        urlIsValid = true
    }

    func addFeed() {
        guard let url = URL(string: urlText), let targetPage = targetPage else { return }

        self.loading = true

        newFeed = Feed.create(in: self.viewContext, page: targetPage, url: url, prepend: true)
        refreshManager.refresh(feed: newFeed!)
    }

    private func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        withAnimation(.default) { validationAttempts += 1 }
    }
}
