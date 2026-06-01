# Mouloudia Web 🛒

Plateforme de vente en ligne développée en Python/Flask avec une base de données relationnelle MySQL, dans le cadre du cours GLO-2005 à l'Université Laval. Projet réalisé en collaboration avec le Mouloudia Club Oujda.

## Stack technique

- **Python** · **Flask** · **MySQL**
- **HTML** · **CSS** · **JavaScript**
- Architecture **MVC** · **REST API**

## Fonctionnalités

- Authentification et gestion des utilisateurs
- Catalogue de produits avec recherche et filtres
- Système de panier et transactions d'achat
- Validation des données côté serveur
- Interface responsive et ergonomique
- Scripts SQL de migration et rollback

## Structure

```
mouloudia-web/
├── Back_end/
│   ├── app/
│   │   ├── routes/       # Routes Flask
│   │   ├── models.py     # Modèles de données
│   │   ├── database.py   # Connexion MySQL
│   │   └── config.py     # Configuration
│   └── sql/
│       ├── script_Projet.sql   # Script principal
│       ├── migrate_1.sql       # Migrations
│       └── rollback_1.sql      # Rollback
└── Front_end/            # Interface utilisateur
```

## Lancer le projet

**Prérequis :** Python 3.x, MySQL

```bash
# Installer les dépendances
pip install -r requirements.txt

# Initialiser la base de données
mysql -u root -p < Back_end/sql/script_Projet.sql

# Lancer l'application
python run.py
```

## Concepts appliqués

- Conception de base de données relationnelle normalisée
- API REST avec Flask et routage modulaire
- Validation et sécurisation des données
- Scripts SQL de migration versionnés

## Équipe

Projet réalisé en équipe — Université Laval, 2023-2024
