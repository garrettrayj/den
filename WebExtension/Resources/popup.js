//
//  popup.js
//  WebExtension
//
//  Created by Garrett Johnson on 7/19/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

// Send scan request to the content script.
function scanActiveTab() {
    browser
        .tabs
        .query({active: true, currentWindow: true})
        .then(function(tabs) {
            browser
                .tabs
                .sendMessage(tabs[0].id, {"subject": "scan"})
                .then(function(results) {
                    if (results.data.length > 0) {
                        createResultsList(results.data);
                    }
                });
        });
}

// Display scan results.
function createResultsList(results) {
    let list = document.createElement("div");
    list.id = "results"
    
    results.forEach(result => {
        list.appendChild(createResultRow(result));
    })
    
    document.body.replaceChildren(list);
}

// Create a feed result row.
function createResultRow(result) {
    let resultRow = document.createElement("div");
    resultRow.classList.add("result")
    
    let description = document.createElement("div");
    description.classList.add('result-description')
    resultRow.appendChild(description);
    
    let title = document.createElement("div");
    title.classList.add('result-description-title')
    title.innerHTML = result.title;
    description.appendChild(title);

    let feedURL = document.createElement("div");
    feedURL.classList.add('result-description-url')
    feedURL.innerHTML = result.url;
    description.appendChild(feedURL);
    
    let openAction = document.createElement("div");
    openAction.classList.add('result-action')
    resultRow.appendChild(openAction);
    
    let openButton = document.createElement("a");
    openButton.classList = "button"
    openButton.innerHTML = '<i id="open-icon"></i>'
    openButton.href = "den:" + result.url
    openAction.appendChild(openButton)
    
    let copyAction = document.createElement("div");
    copyAction.classList.add('result-action')
    resultRow.appendChild(copyAction);
    
    let copyButton = document.createElement("button");
    copyButton.innerHTML = '<i id="copy-icon"></i>'
    copyButton.onclick = function(e) {
        pasteboardCopy(result.url)
    }
    copyAction.appendChild(copyButton)
    
    return resultRow
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

// Load localized strings
document.getElementById("no-feeds-message").innerHTML = browser.i18n.getMessage("no_results");

// Detect feeds and display results
scanActiveTab()
