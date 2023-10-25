// Send a request to scan for feeds to the content script.
function scanActiveTab() {
    browser
        .tabs
        .query({active: true, currentWindow: true})
        .then(function(tabs) {
            browser
                .tabs
                .sendMessage(tabs[0].id, {"subject": "sense"})
                .then(function(results) {
                    if (results.data.length > 0) {
                        createResultsList(results.data);
                    } else {
                        document.getElementById("no-results-message").innerHTML = browser.i18n.getMessage("no_results");
                    }
                });
        });
}

// Display scan results.
function createResultsList(results) {
    let list = document.createElement("div");
    list.id = "results-list"
    
    results.forEach(result => {
        list.appendChild(createResultRow(result));
    })
    
    document.body.replaceChildren(list);
}


// Create a feed result row.
function createResultRow(result) {
    let row = document.createElement("div");
    row.classList.add("row")
    
    let descriptionCol = document.createElement("div");
    descriptionCol.classList.add('description')
    row.appendChild(descriptionCol);
    
    let title = document.createElement("div");
    title.classList.add('title')
    title.innerHTML = result.title;
    descriptionCol.appendChild(title);

    let feedURL = document.createElement("div");
    feedURL.classList.add('feed-url')
    feedURL.innerHTML = result.url;
    descriptionCol.appendChild(feedURL);
    
    let openCol = document.createElement("div");
    openCol.classList.add('action')
    row.appendChild(openCol);
    
    let openBtn = document.createElement("button");
    openBtn.classList.add('open-btn')
    openBtn.innerHTML = '<i id="open-icon"></i>'
    openBtn.onclick = function() {
        window.open("den:" + result.url);
    }
    openCol.appendChild(openBtn)
    
    let copyCol = document.createElement("div");
    copyCol.classList.add('action')
    row.appendChild(copyCol);
    
    let copyBtn = document.createElement("button");
    copyBtn.classList.add('copy-btn')
    copyBtn.innerHTML = '<i id="copy-icon"></i>'
    copyBtn.onclick = function(e) {
        pasteboardCopy(result.url)
    }
    copyCol.appendChild(copyBtn)
    
    return row
}

// Copy text to clipboard
function pasteboardCopy(text) {
    navigator.clipboard.writeText(text);
    
    let copiedMessage = browser.i18n.getMessage("copied", text)
    
    let status = document.createElement("div")
    status.classList.add("status")
    status.innerHTML = copiedMessage
    
    const statuses = document.getElementsByClassName("status")
    let i = 0;
    while (statuses.length) {
        statuses[i].parentNode.removeChild(statuses[i])
    }
    
    document.body.appendChild(status);
}

// Show feeds for the active tab when popup is opened.
scanActiveTab()
