document.getElementById("signup-form").addEventListener("submit", async function(event) {
    event.preventDefault(); // Empêche le rechargement de la page

    const username = document.getElementById("username").value;
    const prenom = document.getElementById("prenom").value;
    const genre = document.getElementById("genre").value;
    const age = document.getElementById("age").value;
    const adresse = document.getElementById("adresse").value;
    const email = document.getElementById("email").value;
    const password = document.getElementById("password").value;
    const confirmPassword = document.getElementById("confirm_password").value;

    if (password !== confirmPassword) {
        document.getElementById("message").textContent = "Les mots de passe ne correspondent pas.";
        return;
    }

    try {
        const response = await fetch("http://127.0.0.1:5000/users/signup", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                username: username,
                prenom: prenom,
                genre: genre,
                age: age,
                adresse: adresse,
                email: email,
                password: password
            })
        });

        const result = await response.json();
        document.getElementById("message").textContent = result.message || result.error;

        if (response.ok) {
            // ✅ Rediriger vers la page d'accueil (accueil.html) après 2 secondes
            setTimeout(() => {
                window.location.href = "accueil.html"; // Remplace ici par la vraie URL de ta page d'accueil
            }, 2000);
        }
    } catch (error) {
        console.error("Erreur :", error);
        document.getElementById("message").textContent = "Erreur lors de l'inscription.";
    }
});
