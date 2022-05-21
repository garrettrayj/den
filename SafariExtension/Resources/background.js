function updateBadge(count) {
    var badgeText = ""
    if (count > 0) {
        badgeText = String(count)
        browser.browserAction.enable()
    } else {
        browser.browserAction.disable()
    }
    
    browser.browserAction.setBadgeText({text: badgeText})
}


browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.subject === "results") {
        updateBadge(request.data.length)
    }
});

browser.tabs.onActivated.addListener(function() {
    updateBadge(0)
})
