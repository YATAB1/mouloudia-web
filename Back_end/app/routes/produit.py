from flask import Blueprint, request, jsonify
from app.database import get_db_connection
from flask_cors import CORS


produit_bp = Blueprint('produit_bp', __name__)
CORS(produit_bp)

@produit_bp.route('/ajouter_produit', methods=['POST'])
def ajouter_produit():
    data = request.get_json()
    nom = data.get('nom')
    prix = data.get('prix')
    image = data.get('image')
    categorie = data.get('categorie')
    description = data.get('description')

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute("CALL ajouter_produit(%s, %s, %s, %s, %s)", (nom, description, categorie, prix, image))

    connection.commit()
    cursor.close()
    connection.close()

    return jsonify({"message": "Produit ajouté avec succès !"}), 201
