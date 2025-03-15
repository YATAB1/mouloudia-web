from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from app.database import get_db_connection

signup_bp = Blueprint('signup', __name__)

@signup_bp.route('/signup', methods=['POST'])
def signup():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    username = data.get('username')
    prenom = data.get('prenom')
    genre = data.get('genre')
    age = data.get('age')
    adresse = data.get('adresse')

    if not email or not password or not username:
        return jsonify({"error": "Tous les champs obligatoires ne sont pas remplis"}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM Client WHERE email = %s", (email,))
    existing_user = cursor.fetchone()
    if existing_user:
        return jsonify({"error": "Cet email est déjà utilisé"}), 400

    hashed_password = generate_password_hash(password)

    cursor.execute("""
        INSERT INTO Client (email, mot_de_passe, nom, prenom, genre, age, adresse) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """, (email, hashed_password, username, prenom, genre, age, adresse))

    connection.commit()
    cursor.close()
    connection.close()

    return jsonify({"message": "Compte créé avec succès !"}), 201
