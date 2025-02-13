document.addEventListener("DOMContentLoaded", function () {
    fetch("util_html/footer.html")
        .then(response => response.text())
        .then(data => {
            document.getElementById("footer-placeholder").innerHTML = data;
        });
});
