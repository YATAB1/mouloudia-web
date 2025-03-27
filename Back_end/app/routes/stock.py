from flask import Blueprint, request, jsonify
from app.database import get_db_connection
from flask_cors import CORS

stock_bp = Blueprint('stock', __name__)
CORS(stock_bp)

@stock_bp.route('/ajouter_stock', methods=['POST'])
def ajouter_stock():
    data = request.get_json()

    id_produit = data.get('id_produit')
    id_taille = data.get('id_taille')
    quantite = data.get('quantite')

    if not id_produit or not id_taille or quantite is None:
        return jsonify({"error": "Données incomplètes"}), 400

    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        cursor.execute("CALL ajouter_stock(%s, %s, %s)", (id_produit, id_taille, quantite))
        connection.commit()
        return jsonify({"message": "Stock ajouté avec succès"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        connection.close()
