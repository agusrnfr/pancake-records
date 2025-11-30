document.addEventListener("turbo:load", () => {
    const params = new URLSearchParams(window.location.search);
    const anchor = params.get("anchor");
    if (anchor) {
        location.hash = anchor;
    }
});