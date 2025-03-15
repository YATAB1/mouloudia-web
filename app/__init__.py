from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from dotenv import load_dotenv
import os

# Charger les variables d'environnement
load_dotenv()

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    
    # Charger la configuration
    app.config.from_object("app.config.Config")

    # Initialiser la base de données
    db.init_app(app)
    migrate.init_app(app, db)

    # Importer et enregistrer les routes
    from app.routes.signup import signup_bp
    from app.routes.signin import signin_bp
    app.register_blueprint(signup_bp, url_prefix="/users")
    app.register_blueprint(signin_bp, url_prefix="/users")

    return app
