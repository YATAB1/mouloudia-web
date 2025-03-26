from flask import Blueprint

# Créer un Blueprint global
user_bp = Blueprint('user_bp', __name__)

# Importer les fichiers de routes
from app.routes.signup import *
from app.routes.signin import *

# Enregistrer le Blueprint dans `app/__init__.py`
