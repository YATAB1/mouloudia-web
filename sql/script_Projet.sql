USE boutique_db;

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


