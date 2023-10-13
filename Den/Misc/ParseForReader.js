function parseForReader() {
    Mercury.parse(document.URL).then(function(result) {
        window.webkit.messageHandlers.reader.postMessage(JSON.stringify(result));
    });
}

window.addEventListener("pageshow", function(event) {
    if (event.persisted) {
        parseForReader();
    }
});

document.addEventListener("DOMContentLoaded", function() {
    parseForReader();
});
