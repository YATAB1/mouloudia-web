from flask import Flask
from flask_cors import CORS
from app.routes.signup import signup_bp
from app.routes.signin import signin_bp
from app.routes.produit import produit_bp
from app.routes.stock import stock_bp
from app.database import get_db_connection

def create_app():
    app = Flask(__name__)
    CORS(app)
    app = Flask(__name__, static_folder="../Front_end", static_url_path="/Front_end")

    app.register_blueprint(signup_bp, url_prefix='/users')
    app.register_blueprint(signin_bp, url_prefix='/users')
    app.register_blueprint(produit_bp, url_prefix='/produits')
    app.register_blueprint(stock_bp, url_prefix='/stock')
    
    @app.route('/Front_end/<path:filename>')
    def serve_static(filename):
        return send_from_directory(app.static_folder, filename)

    return app
