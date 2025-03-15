from flask import Blueprint, request, jsonify
from werkzeug.security import check_password_hash
from app.database import get_db_connection

signin_bp = Blueprint('signin', __name__)

@signin_bp.route('/signin', methods=['POST'])
def signin():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({"error": "Email et mot de passe requis"}), 400

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("SELECT * FROM Client WHERE email = %s", (email,))
    user = cursor.fetchone()

    if not user or not check_password_hash(user['mot_de_passe'], password):
        return jsonify({"error": "Email ou mot de passe incorrect"}), 401

    cursor.close()
    connection.close()

    return jsonify({"message": "Connexion réussie !"}), 200
