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
