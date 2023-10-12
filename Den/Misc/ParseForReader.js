document.addEventListener("DOMContentLoaded", (event) => {
    Mercury.parse(document.URL).then(function(result) {
        window.webkit.messageHandlers.reader.postMessage(JSON.stringify(result));
    });
});
