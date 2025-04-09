USE boutique_db;

-- ===========================
-- TABLE CLIENT
-- ===========================
DROP TABLE IF EXISTS Client;

CREATE TABLE Client (
    id_client INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(50) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    nom VARCHAR(25),
    prenom VARCHAR(20),
    genre VARCHAR(10),
    age INT,
    adresse VARCHAR(45)
);


--  Création de la procédure stockée ajouter_utilisateur
DROP PROCEDURE IF EXISTS ajouter_utilisateur;
DELIMITER //
CREATE PROCEDURE ajouter_utilisateur(
    IN p_email VARCHAR(50),
    IN p_mot_de_passe VARCHAR(255),
    IN p_nom VARCHAR(25)
)
BEGIN
    DECLARE compte INT;
    
    -- Vérifier si l'email existe déjà
    SELECT COUNT(*) INTO compte FROM Client WHERE email = p_email;
    
    IF compte = 0 THEN
        -- Ajouter l'utilisateur (id_client est généré automatiquement)
        INSERT INTO Client (email, mot_de_passe, nom) 
        VALUES (p_email, p_mot_de_passe, p_nom);
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cet email est déjà utilisé';
    END IF;
END//
DELIMITER ;


DROP FUNCTION IF EXISTS emailExiste;
DELIMITER //
CREATE FUNCTION emailExiste(emailE VARCHAR(50)) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE EXISTE INT;
    SELECT COUNT(*) INTO EXISTE FROM Client WHERE email = emailE;
    RETURN EXISTE;
END//
DELIMITER ;


-- ===========================
-- TABLE PRODUIT
-- ===========================

CREATE TABLE Produit (
    id_produit INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    categorie VARCHAR(100),
    prix DECIMAL(10, 2) NOT NULL,
    image VARCHAR(255),
    description TEXT
);

CREATE PROCEDURE ajouter_produit(
    IN p_nom VARCHAR(100),
    IN p_description TEXT,
    IN p_categorie VARCHAR(50),
    IN p_prix DECIMAL(10,2),
    IN p_image VARCHAR(255)
)

-- ===========================
-- TABLE TAILLE
-- ===========================

 CREATE TABLE Taille (
    id_taille INT AUTO_INCREMENT PRIMARY KEY,
    libelle VARCHAR(20) NOT NULL
);

-- ===========================
-- TABLE STOCK
-- ===========================

CREATE TABLE Stock (
    id_stock INT AUTO_INCREMENT PRIMARY KEY,
    id_produit INT,
    id_taille INT,
    quantite_dispo INT,

    FOREIGN KEY (id_produit) REFERENCES Produit(id_produit),
    FOREIGN KEY (id_taille) REFERENCES Taille(id_taille)
);


DELIMITER //

DROP PROCEDURE IF EXISTS ajouter_produit;
CREATE PROCEDURE ajouter_produit(
    IN p_nom VARCHAR(100),
    IN p_description TEXT,
    IN p_categorie VARCHAR(50),
    IN p_prix DECIMAL(10,2),
    IN p_image VARCHAR(255)
)
BEGIN
    INSERT INTO Produit (nom, description, categorie, prix, image)
    VALUES (p_nom, p_description, p_categorie, p_prix, p_image);
END //

DELIMITER ;


DELIMITER //
DROP PROCEDURE IF EXISTS ajouter_stock;
CREATE PROCEDURE ajouter_stock(
    IN p_id_produit INT,
    IN p_id_taille INT,
    IN p_quantite INT
)
BEGIN
    INSERT INTO Stock (id_produit, id_taille, quantite_dispo)
    VALUES (p_id_produit, p_id_taille, p_quantite);
END //
DELIMITER ;










-- ===========================
-- TABLE COMMANDE
-- ===========================
DROP TABLE IF EXISTS Commande;
CREATE TABLE Commande (
    id_commande INT AUTO_INCREMENT PRIMARY KEY,
    id_client INT NOT NULL,
    date_commande DATE DEFAULT (CURDATE()),
    statut ENUM('en traitement', 'expédiée', 'livrée') DEFAULT 'en traitement',
    FOREIGN KEY (id_client) REFERENCES Client(id_client)
);

-- ===========================
-- TABLE LIGNE_COMMANDE
-- ===========================
DROP TABLE IF EXISTS Ligne_Commande;
CREATE TABLE Ligne_Commande (
    id_ligne INT AUTO_INCREMENT PRIMARY KEY,
    id_commande INT NOT NULL,
    id_produit INT NOT NULL,
    quantite INT NOT NULL CHECK (quantite > 0),
    prix_unitaire DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_commande) REFERENCES Commande(id_commande),
    FOREIGN KEY (id_produit) REFERENCES Produit(id_produit)
);

-- ===========================
-- TABLE PANIER
-- ===========================
DROP TABLE IF EXISTS Panier;
CREATE TABLE Panier (
    id_panier INT AUTO_INCREMENT PRIMARY KEY,
    id_client INT NOT NULL,
    id_produit INT NOT NULL,
    quantite INT NOT NULL CHECK (quantite > 0),
    date_ajout DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_client) REFERENCES Client(id_client),
    FOREIGN KEY (id_produit) REFERENCES Produit(id_produit)
);

-- ===========================
-- PROCEDURE : ajouter au panier
-- ===========================
DROP PROCEDURE IF EXISTS ajouter_au_panier;
DELIMITER //
CREATE PROCEDURE ajouter_au_panier( IN p_id_client INT, IN p_id_produit INT, IN p_quantite INT)
BEGIN
    DECLARE existe INT;

    SELECT COUNT(*) INTO existe
    FROM Panier
    WHERE id_client = p_id_client AND id_produit = p_id_produit;

    IF existe = 0 THEN
        INSERT INTO Panier (id_client, id_produit, quantite)
        VALUES (p_id_client, p_id_produit, p_quantite);
    ELSE
        UPDATE Panier
        SET quantite = quantite + p_quantite
        WHERE id_client = p_id_client AND id_produit = p_id_produit;
    END IF;
END;
//
DELIMITER ;

-- ===========================
-- PROCEDURE : retirer un produit du panier
-- ===========================
DROP PROCEDURE IF EXISTS retirer_du_panier;
DELIMITER //
CREATE PROCEDURE retirer_du_panier( IN p_id_client INT, IN p_id_produit INT)
BEGIN
    DELETE FROM Panier
    WHERE id_client = p_id_client AND id_produit = p_id_produit;
END;
//
DELIMITER ;

-- ===========================
-- FONCTION : obtenir le total du panier
-- ===========================
DROP FUNCTION IF EXISTS obtenir_total_panier(p_client_id INT)
DELIMITER //
CREATE FUNCTION obtenir_total_panier(p_client_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(p.quantite * pr.prix) INTO total
    FROM Panier p
    JOIN Produit pr ON p.id_produit = pr.id_produit
    WHERE p.id_client = p_client_id;

    RETURN IFNULL(total, 0);
END //
DELIMITER ;


-- ===========================
-- PROCEDURE : vider le panier
-- ===========================
DROP PROCEDURE IF EXISTS vider_panier;
DELIMITER //
CREATE PROCEDURE vider_panier(IN p_id_client INT)
BEGIN
    DELETE FROM Panier
    WHERE id_client = p_id_client;
END;
//
DELIMITER ;

-- ===========================
-- PROCEDURE : valider panier => créer commande
-- ===========================
DROP PROCEDURE IF EXISTS valider_panier;
DELIMITER //
CREATE PROCEDURE valider_panier(IN p_id_client INT)
BEGIN
    DECLARE p_id_commande INT;

    -- Créer une commande
    INSERT INTO Commande(id_client) VALUES (p_id_client);
    SET p_id_commande = LAST_INSERT_ID();

    -- Ajouter les lignes de commande depuis le panier
    INSERT INTO Ligne_Commande (id_commande, id_produit, quantite, prix_unitaire)
    SELECT
        p_id_commande,
        P.id_produit,
        P.quantite,
        Pr.prix
    FROM Panier P
    JOIN Produit Pr ON P.id_produit = Pr.id_produit
    WHERE P.id_client = p_id_client;

    -- Vider le panier après commande
    DELETE FROM Panier WHERE id_client = p_id_client;
END;
//
DELIMITER ;

-- ===========================
-- FONCTION : produit dans le panier
-- ===========================
DROP FUNCTION IF EXISTS produitDansPanier;
DELIMITER //
CREATE FUNCTION produitDansPanier(p_id_client INT,p_id_produit INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe INT;
    SELECT COUNT(*) INTO existe
    FROM Panier
    WHERE id_client = p_id_client AND id_produit = p_id_produit;

    RETURN (existe > 0);
END;
//
DELIMITER ;

-- ===========================
-- PROCEDURE : afficher les commandes d’un client
-- ===========================
DROP PROCEDURE IF EXISTS afficher_commandes;
DELIMITER //
CREATE PROCEDURE afficher_commandes(IN p_id_client INT)
BEGIN
    SELECT *
    FROM Commande
    WHERE id_client = p_id_client
    ORDER BY date_commande DESC;
END;
//
DELIMITER ;

-- ===========================
-- PROCEDURE : afficher les détails d’une commande
-- ===========================
DROP PROCEDURE IF EXISTS afficher_details_commande;
DELIMITER //
CREATE PROCEDURE afficher_details_commande(IN p_id_commande INT)
BEGIN
    SELECT
        LC.id_ligne,
        P.nom AS nom_produit,
        P.description,
        LC.quantite,
        LC.prix_unitaire,
        (LC.quantite * LC.prix_unitaire) AS total_ligne
    FROM Ligne_Commande LC
    JOIN Produit P ON LC.id_produit = P.id_produit
    WHERE LC.id_commande = p_id_commande;
END;
//
DELIMITER ;


-- ===========================
-- PROCEDURE : annuler une commande
-- ===========================
DROP PROCEDURE IF EXISTS annuler_commande;
DELIMITER //
CREATE PROCEDURE annuler_commande(IN p_id_commande INT)
BEGIN
    UPDATE Commande
    SET statut = 'en traitement'
    WHERE id_commande = p_id_commande AND statut <> 'expédiée';
END;
//
DELIMITER ;


-- ===========================
-- PROCEDURE : mettre à jour le stock d’un produit
-- ===========================
DROP PROCEDURE IF EXISTS mettre_a_jour_stock;
DELIMITER //
CREATE PROCEDURE mettre_a_jour_stock(IN p_id_produit INT, IN p_quantite INT)
BEGIN
    UPDATE Produit
    SET stock = stock - p_quantite
    WHERE id_produit = p_id_produit;
END;
//
DELIMITER ;
