function fixImageSize() {
    document.querySelectorAll("img").forEach(function(img) {
        // Set image size attributes so junk 1x1 images can be hidden via CSS
        if (img.getAttribute("width") === null) {
            img.setAttribute("width", img.clientWidth);
        }
        if (img.getAttribute("height") === null) {
            img.setAttribute("height", img.clientHeight);
        }
        
        // Remove border (outline) on small images
        if (img.width < 200 || img.height < 200) {
            img.classList.add("den-no-border");
        }
    });
}

function fixImageSrcset() {
    document.querySelectorAll("img").forEach(function(img) {
        // Remove "data:" srcset attributes (www.thestreet.com)
        var srcset = img.getAttribute("srcset");
        if (typeof srcset === "string" && srcset.slice(0, 4) === "data") {
            img.removeAttribute("srcset");
        }
    });
}

function fixIframeScaling() {
    document.querySelectorAll("iframe").forEach(function(iframe) {
        if (iframe.hasAttribute("width") && iframe.hasAttribute("height")) {
            iframe.style.aspectRatio = iframe.width + "/" + iframe.height;
        }
    });
}

document.addEventListener('readystatechange', event => {
    switch (document.readyState) {
        case "loading":
        break;
    case "interactive":
        fixIframeScaling();
        break;
    case "complete":
        fixImageSrcset();
        fixImageSize();
        break;
    }
});
