function parseForReader() {
    Mercury.parse().then(function(result) {
        window.webkit.messageHandlers.reader.postMessage(JSON.stringify(result));
    });
}

window.addEventListener("pageshow", function(event) {
    parseForReader();
});
