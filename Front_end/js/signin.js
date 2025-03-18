document.getElementById("signin-form").addEventListener("submit", async function(event) {
    event.preventDefault(); // Empêche le rechargement de la page

    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;

    try {
        const response = await fetch("http://127.0.0.1:5000/users/signin", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                email: email,
                password: password
            })
        });

        const result = await response.json();
        document.getElementById("message").textContent = result.message || result.error;

        if (response.ok) {
            // ✅ Sauvegarde du token (si ton backend envoie un token)
            if (result.token) {
                localStorage.setItem("authToken", result.token);
            }

            // ✅ Rediriger vers la page d'accueil (accueil.html) après 2 secondes
            setTimeout(() => {
                window.location.href = "accueil.html"; // Remplace ici par la vraie URL de ta page d'accueil
            }, 2000);
        }
    } catch (error) {
        console.error("Erreur :", error);
        document.getElementById("message").textContent = "Erreur lors de la connexion.";
    }
});
