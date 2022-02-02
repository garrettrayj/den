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
    let viewContext: NSManagedObjectContext
    let profileManager: ProfileManager
    let refreshManager: RefreshManager

    @Published var page: Page?
    @Published var urlText: String = ""
    @Published var urlIsValid: Bool?
    @Published var validationAttempts: Int = 0
    @Published var validationMessage: String?
    @Published var loading: Bool = false

    var newFeed: Feed?

    func checkTargetPage() {
        // Use the currently active page if available
        if page != nil {
            return
        }

        // Fallback to the first page in profile
        if
            let profile = profileManager.activeProfile,
            let page = profile.pagesArray.first
        {
            self.page = page
        }

        // No destination, user will see prompt to create a page
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

        checkTargetPage()
    }

    func validateUrl() {
        validationMessage = nil
        urlIsValid = nil

        if urlText == "" {
            self.failValidation(message: "Address can not be blank")
            return
        }

        if self.urlText.contains(" ") {
            self.failValidation(message: "Address can not contain spaces")
            return
        }

        if self.urlText.prefix(7).lowercased() != "http://" && self.urlText.prefix(8).lowercased() != "https://" {
            self.failValidation(message: "Address must begin with “http://” or “https://”")
            return
        }

        guard let url = URL(string: self.urlText) else {
            self.failValidation(message: "Unable to parse address")
            return
        }

        if !UIApplication.shared.canOpenURL(url) {
            self.failValidation(message: "Unopenable address")
            return
        }

        urlIsValid = true
    }

    func addFeed() {
        guard let url = URL(string: urlText), let page = page else { return }

        self.loading = true

        newFeed = Feed.create(in: self.viewContext, page: page, url: url, prepend: true)
        refreshManager.refresh(feed: newFeed!)
    }

    private func failValidation(message: String) {
        urlIsValid = false
        validationMessage = message

        withAnimation(.default) { validationAttempts += 1 }
    }
}
