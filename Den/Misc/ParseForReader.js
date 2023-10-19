window.addEventListener("pageshow", function(event) {
    Mercury.parse().then(function(result) {
        window.webkit.messageHandlers.reader.postMessage(JSON.stringify(result));
    });
});
