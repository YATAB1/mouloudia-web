document.addEventListener("DOMContentLoaded", function () {
    fetch("accueil/history_section.html")
        .then(response => response.text())
        .then(data => {
            document.getElementById("historysection-placeholder").innerHTML = data;
        });
});
