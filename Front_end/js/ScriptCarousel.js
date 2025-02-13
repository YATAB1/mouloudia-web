document.addEventListener("DOMContentLoaded", function () {
    fetch("carousel.html")
        .then(response => response.text())
        .then(data => {
            document.getElementById("carousel").innerHTML = data;
        });
});
