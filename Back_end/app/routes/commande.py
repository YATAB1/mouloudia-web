from flask import Blueprint, session, redirect
from app.database import get_db_connection

commande_bp = Blueprint('commande', __name__)

# j'ai oublié cette focntion fait quoi 
@commande_bp.route('/commander', methods=['POST'])
def valider_commande():
    id_client = session.get('id_client')

    db = get_db()
    cursor = db.cursor()
    cursor.callproc('valider_panier', (id_client,))
    db.commit()

    return redirect('/mes_commandes')  # à créer plus tard pour afficher historique


# ===========================
# ROUTE : afficher commandes d’un client
# ===========================
@commande_bp.route('/afficher_commandes/<int:id_client>', methods=['GET'])
def afficher_commandes(id_client):
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.callproc('afficher_commandes', [id_client])
    result = cursor.fetchall()

    commandes = []
    for row in result:
        commandes.append({
            "id_commande": row[0],
            "id_client": row[1],
            "date_commande": row[2].strftime('%Y-%m-%d'),
            "statut": row[3]
        })

    cursor.close()
    connection.close()
    return jsonify(commandes), 200


# ===========================
# ROUTE : afficher détails d’une commande
# ===========================
@commande_bp.route('/afficher_details/<int:id_commande>', methods=['GET'])
def afficher_details_commande(id_commande):
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.callproc('afficher_details_commande', [id_commande])
    result = cursor.fetchall()

    details = []
    for row in result:
        details.append({
            "id_ligne": row[0],
            "nom_produit": row[1],
            "description": row[2],
            "quantite": row[3],
            "prix_unitaire": float(row[4]),
            "total_ligne": float(row[5])
        })

    cursor.close()
    connection.close()
    return jsonify(details), 200


# ===========================
# ROUTE : annuler une commande
# ===========================
@commande_bp.route('/annuler_commande/<int:id_commande>', methods=['POST'])
def annuler_commande(id_commande):
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.callproc('annuler_commande', [id_commande])
    connection.commit()

    cursor.close()
    connection.close()
    return jsonify({"message": "Commande annulée (si non expédiée)."}), 200


# ===========================
# ROUTE : mise à jour du stock (admin)
# ===========================
@commande_bp.route('/mettre_a_jour_stock', methods=['POST'])
def mettre_a_jour_stock():
    data = request.get_json()
    id_produit = data.get("id_produit")
    quantite = data.get("quantite")

    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.callproc('mettre_a_jour_stock', [id_produit, quantite])
    connection.commit()

    cursor.close()
    connection.close()
    return jsonify({"message": "Stock mis à jour avec succès."}), 200