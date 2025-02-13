document.addEventListener("DOMContentLoaded", function () {
    fetch("util_html/header.html")
        .then(response => response.text())
        .then(data => {
            document.getElementById("header-placeholder").innerHTML = data;
        });
});
