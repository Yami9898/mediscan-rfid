-- Base eHealth : structure + un patient de démonstration (données fictives)
-- eHealth database: schema + one demo patient (fake data)

CREATE DATABASE IF NOT EXISTS ehealth DEFAULT CHARACTER SET utf8mb4;
USE ehealth;

CREATE TABLE IF NOT EXISTS `patients` (
  `id` varchar(50) NOT NULL,  -- = UID de la carte RFID / RFID card UID
  `civilite` enum('Mr.','Mme.') NOT NULL,
  `nom` varchar(50) NOT NULL,
  `prenom` varchar(50) NOT NULL,
  `date_naissance` date DEFAULT NULL,
  `sexe` enum('M','F') NOT NULL,
  `nationalite` varchar(50) NOT NULL,
  `ville` varchar(50) NOT NULL,
  `adresse` text,
  `telephone` varchar(20) DEFAULT NULL,
  `e_mail` varchar(100) DEFAULT NULL,
  `num_cin` varchar(20) NOT NULL,
  `prise_en_charge` text,
  `photo_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `rdv` (
  `num_rdv` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `heure` time NOT NULL,
  `lieu` text NOT NULL,
  `motif` enum('Consultation','Chirurgie','Analyses médicales','Imagerie','vaccin') NOT NULL,
  `type` varchar(50) DEFAULT NULL,
  `id_patient` varchar(50) NOT NULL,
  `statut` enum('En attente','Annulé','Terminé') DEFAULT 'En attente',
  PRIMARY KEY (`num_rdv`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `consultations` (
  `num_consultation` int NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `etablissement` text NOT NULL,
  `medecin` text NOT NULL,
  `specialite` text NOT NULL,
  `ordonnance` varchar(255) DEFAULT NULL,
  `pv` text,
  `id_patient` varchar(50) NOT NULL,
  `maladie` text NOT NULL,
  `traitement` longtext,
  `statut` enum('en cours','terminé') DEFAULT 'en cours',
  PRIMARY KEY (`num_consultation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `vaccins` (
  `num_vaccin` int NOT NULL AUTO_INCREMENT,
  `nom` text NOT NULL,
  `type` enum('Viral','Bactérien','Combiné') NOT NULL,
  `date` date NOT NULL,
  `dose` enum('1ère','2ème','Rappel') NOT NULL,
  `voie` enum('IM','SC','ID','Orale','Nasale') NOT NULL,
  `lieu` text NOT NULL,
  `responsable` text NOT NULL,
  `id_patient` varchar(50) NOT NULL,
  PRIMARY KEY (`num_vaccin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `maladies` (
  `num_maladie` int NOT NULL AUTO_INCREMENT,
  `maladie` varchar(50) NOT NULL,
  `type` enum('Chronique','Allergie','Cancer','Auto-immune rare') NOT NULL,
  `historique_trait` longtext,
  `avancement` longtext,
  `date_debut` date NOT NULL,
  `date_fin` date DEFAULT NULL,
  `id_patient` varchar(50) NOT NULL,
  PRIMARY KEY (`num_maladie`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patient de démonstration : tapez DEMO001 dans l'interface puis ✓
-- Demo patient: type DEMO001 in the interface then ✓
INSERT IGNORE INTO patients
  (id, civilite, nom, prenom, date_naissance, sexe, nationalite, ville, adresse,
   telephone, e_mail, num_cin, prise_en_charge, photo_url)
VALUES
  ('DEMO001', 'Mr.', 'DUPONT', 'Jean', '1990-05-14', 'M', 'Française', 'Paris',
   '1 rue de la Démo', '0600000000', 'jean.dupont@example.com', 'AB000000', 'CNSS', NULL);

INSERT INTO rdv (date, heure, lieu, motif, type, id_patient, statut)
SELECT '2026-12-01', '10:30:00', 'Cabinet Démo', 'Consultation', 'Contrôle', 'DEMO001', 'En attente'
WHERE NOT EXISTS (SELECT 1 FROM rdv WHERE id_patient = 'DEMO001');

INSERT INTO vaccins (nom, type, date, dose, voie, lieu, responsable, id_patient)
SELECT 'Grippe saisonnière', 'Viral', '2025-10-15', '1ère', 'IM', 'Cabinet Démo', 'Dr. Démo', 'DEMO001'
WHERE NOT EXISTS (SELECT 1 FROM vaccins WHERE id_patient = 'DEMO001');
