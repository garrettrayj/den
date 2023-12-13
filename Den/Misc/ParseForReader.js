function parseForReader() {
    Mercury.parse(window.location.href).then(function(result) {
        window.webkit.messageHandlers.reader.postMessage(JSON.stringify(result));
    });
}

window.addEventListener("pageshow", function(event) {
    if (event.persisted) {
        parseForReader();
    }
});

parseForReader();
