browser.tabs.onActivated.addListener(function(activeInfo) {
    // Toolbar button disabled by default
    browser.browserAction.disable()
    
    browser
        .tabs
        .sendMessage(activeInfo.tabId, {"subject": "sense", "sender": "popup"})
        .then(function(results) {
            let count = results.data.length
            if (count > 0) {
                browser.browserAction.setBadgeText({tabId: activeInfo.tabId, text: String(count)})
                browser.browserAction.enable()
            }
        });
});
