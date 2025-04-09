from flask import Blueprint, request, session, redirect, render_template
from app.database import get_db_connection

panier_bp = Blueprint('panier', __name__)

@panier_bp.route('/panier/ajouter', methods=['POST'])
def ajouter_au_panier():
    id_client = session.get('id_client')
    id_produit = request.form['id_produit']
    quantite = request.form['quantite']

    db = get_db()
    cursor = db.cursor()
    cursor.callproc('ajouter_au_panier', (id_client, id_produit, quantite))
    db.commit()
    return redirect('/panier')


@panier_bp.route('/panier')
def afficher_panier():
    id_client = session.get('id_client')

    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT P.id_produit, PR.nom, P.quantite, PR.prix,
               (P.quantite * PR.prix) AS total
        FROM Panier P
        JOIN Produit PR ON P.id_produit = PR.id_produit
        WHERE P.id_client = %s
    """, (id_client,))
    
    panier = cursor.fetchall()
    total_general = sum([item['total'] for item in panier])

    return render_template('panier.html', panier=panier, total=total_general)


@panier_bp.route('/panier/retirer', methods=['POST'])
def retirer_du_panier():
    id_client = session.get('id_client')
    id_produit = request.form['id_produit']

    db = get_db()
    cursor = db.cursor()
    cursor.callproc('retirer_du_panier', (id_client, id_produit))
    db.commit()

    return redirect('/panier')



@panier_bp.route('/panier/valider', methods=['POST'])
def valider_panier():
    id_client = session.get('id_client')

    if not id_client:
        return redirect('/connexion')  # ou retourner une erreur si besoin

    db = get_db()
    cursor = db.cursor()

    try:
        cursor.callproc('valider_panier', (id_client,))
        db.commit()
    except Exception as e:
        db.rollback()
        return f"Erreur lors de la validation du panier : {e}", 500
    finally:
        cursor.close()

    return redirect('/commande/confirmation')  # Redirige vers une page de confirmation
