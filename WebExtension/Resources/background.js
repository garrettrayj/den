//
//  background.js
//  WebExtension
//
//  Created by Garrett Johnson on 10/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

function updateBadge(tabId, count) {
    if (count > 0) {
        browser.browserAction.setBadgeText({tabId: tabId, text: String(count)});
        browser.browserAction.enable(tabId);
    } else {
        browser.browserAction.disable(tabId);
    }
}

browser.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
    browser
        .tabs
        .sendMessage(tabId, {"subject": "scan"})
        .then(function(results) {
            updateBadge(tabId, results.data.length)
        });
});
