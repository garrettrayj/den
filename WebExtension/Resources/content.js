const formats = {
    "application/rss+xml": "RSS",
    "application/atom+xml": "Atom",
    "application/feed+json": "JSON Feed"
}

// Detect syndication feeds configured for auto-discovery.
function senseFeeds() {
    let selectors = [];
    for (const [type, name] of Object.entries(formats)) {
        selectors.push('link[type="' + type + '"]');
    }
    const links = Array.from(document.querySelectorAll(selectors.join(", ")));
    
    return links.flatMap(extractResult);
}

// No matter how you pass in the URL string, the URL will come out absolute.
let getAbsoluteUrl = (function() {
    let a;

    return function(url) {
        if(!a) a = document.createElement('a');
        a.href = url;

        return a.href;
    };
})();


// Returns a 1-element array to keep the item, or a 0-element array to remove the item.
function extractResult(el) {
    if (!el.hasAttribute("href")) { return [] }
    
    const type = el.getAttribute("type")
    const url = getAbsoluteUrl(el.getAttribute("href"))
    
    let title = formats[type]
    if (el.hasAttribute("title")) {
        title = el.getAttribute("title")
    }
    
    return [{"title": title, "url": url}]
}

let feeds = senseFeeds();

// Initial toolbar count
browser.runtime.sendMessage({"subject": "results", "data": feeds});

// Update toolbar count for pages already initialized
window.addEventListener("pageshow", (event) => {
    if (event.persisted) {
        browser.runtime.sendMessage({"subject": "results", "data": feeds});
    }
});

// Respond to requests from extension popup script
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.subject == "sense") {
        sendResponse({"subject": "results", "data": feeds});
    }
});
