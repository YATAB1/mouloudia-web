from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from app.database import get_db_connection
from flask_cors import CORS

signup_bp = Blueprint('signup', __name__)
CORS(signup_bp)  # Autorise CORS sur ce Blueprint

@signup_bp.route('/signup', methods=['POST', 'OPTIONS'])
def signup():
    if request.method == "OPTIONS":
        return jsonify({"message": "CORS preflight OK"}), 200

    data = request.get_json()
    print("📥 Données reçues :", data)  # 🔥 DEBUG

    email = data.get('email')
    password = data.get('password')
    username = data.get('username')
    prenom = data.get('prenom')
    genre = data.get('genre')
    age = data.get('age')
    adresse = data.get('adresse')

    if not email or not password or not username:
        print("❌ Champs obligatoires manquants")  # 🔥 DEBUG
        return jsonify({"error": "Tous les champs obligatoires ne sont pas remplis"}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM Client WHERE email = %s", (email,))
    existing_user = cursor.fetchone()
    if existing_user:
        print("❌ Email déjà utilisé")  # 🔥 DEBUG
        return jsonify({"error": "Cet email est déjà utilisé"}), 400

    hashed_password = generate_password_hash(password)
    print("🔐 Mot de passe hashé :", hashed_password)  # 🔥 DEBUG

    print("📌 Insertion en base de données...")  # 🔥 DEBUG
    cursor.execute("""
        INSERT INTO Client (email, mot_de_passe, nom, prenom, genre, age, adresse) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (email, hashed_password, username, prenom, genre, age, adresse))

    connection.commit()
    cursor.close()
    connection.close()
    print("✅ Utilisateur ajouté avec succès")  # 🔥 DEBUG

    return jsonify({"message": "Compte créé avec succès !"}), 201
