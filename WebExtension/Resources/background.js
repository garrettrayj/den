function updateBadge(tabId, count) {
    if (count > 0) {
        browser.browserAction.setBadgeText({tabId: tabId, text: String(count)});
        browser.browserAction.enable(tabId);
    } else {
        browser.browserAction.disable(tabId)
    }
}

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.subject === "results") {
        updateBadge(sender.tab.id, request.data.length)
    }
});

browser.tabs.onActivated.addListener(function(activeInfo) {
    browser.browserAction.disable(tabId)
});
 
browser.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
    if (tab.url === "") {
        browser.browserAction.disable(tabId)
    }
});

