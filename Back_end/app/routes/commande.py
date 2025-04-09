from flask import Blueprint, session, redirect
from app.database import get_db_connection

commande_bp = Blueprint('commande', __name__)

@commande_bp.route('/commander', methods=['POST'])
def valider_commande():
    id_client = session.get('id_client')

    db = get_db()
    cursor = db.cursor()
    cursor.callproc('valider_panier', (id_client,))
    db.commit()

    return redirect('/mes_commandes')  # à créer plus tard pour afficher historique
