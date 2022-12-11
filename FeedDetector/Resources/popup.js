/**
 Send a request to scan for feeds to the content script.
 */
function scanActiveTab() {
    browser
        .tabs
        .query({active: true, currentWindow: true})
        .then((tabs) => {
            browser.tabs.sendMessage(tabs[0].id, {"subject": "sense", "sender": "popup"}).then(results => {
                if (results.data.length > 0) {
                    createResultsList(results.data)
                }
            });
        });
}

/**
 Display detectected feeds.
 */
function createResultsList(results) {
    var list = document.createElement("div");
    list.id = "results-list"
    
    results.forEach(result => {
        list.appendChild(createResultRow(result));
    })
    
    document.body.replaceChildren(list);
}

/**
 Create a row for a single feed result.
 */
function createResultRow(result) {
    var row = document.createElement("div");
    row.classList.add("row")
    
    var descriptionCol = document.createElement("div");
    descriptionCol.classList.add('description')
    row.appendChild(descriptionCol);
    
    var title = document.createElement("div");
    title.classList.add('title')
    title.innerHTML = result.title;
    descriptionCol.appendChild(title);

    var feedURL = document.createElement("div");
    feedURL.classList.add('feed-url')
    feedURL.innerHTML = result.url;
    descriptionCol.appendChild(feedURL);
    
    var openCol = document.createElement("div");
    openCol.classList.add('action')
    row.appendChild(openCol);
    
    var openBtn = document.createElement("button");
    openBtn.classList.add('open-btn')
    openBtn.innerHTML = '<i class="open-icon"></i>'
    openBtn.onclick = function() {
        window.open("den:" + result.url);
    }
    openCol.appendChild(openBtn)
    
    var copyCol = document.createElement("div");
    copyCol.classList.add('action')
    row.appendChild(copyCol);
    
    var copyBtn = document.createElement("button");
    copyBtn.classList.add('copy-btn')
    copyBtn.innerHTML = '<i class="copy-icon"></i>'
    copyBtn.onclick = function(e) {
        pasteboardCopy(result.url)
    }
    copyCol.appendChild(copyBtn)
    
    return row
}

/**
 Copy text to clipboard
 */
function pasteboardCopy(text) {
    navigator.clipboard.writeText(text);
    
    var status = document.createElement("div")
    status.classList.add("status")
    status.innerHTML = '<div>Copied &ldquo;</div><div class="subject">' + text + "</div><div>&rdquo;</div>";
    
    const statuses = document.getElementsByClassName("status")
    var i = 0;
    while (statuses.length) {
        statuses[i].parentNode.removeChild(statuses[i])
    }
    
    document.body.appendChild(status);
}

/**
 Show feeds for the active tab when popup is opened.
 */
scanActiveTab()
