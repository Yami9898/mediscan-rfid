# MediScan — Dossier patient par carte RFID

Français | [English](README.en.md)

Interface web (Flask) qui ouvre le **dossier médical d'un patient en scannant sa carte RFID**.
Le médecin pose la carte sur le lecteur → le dossier s'affiche : identité, rendez-vous, consultations, vaccins, maladies chroniques, ordonnances.

---

## Comment ça marche : carte patient → dossier

```
 Carte RFID patient
        │  (UID de la carte)
        ▼
 Lecteur RC522  ──SPI──►  Arduino  ──USB série (9600 bauds)──►  Flask (app.py)  ──►  MySQL
                                                                     │
                                                                     ▼
                                                        Fiche patient dans le navigateur
```

1. Le médecin clique sur le bouton **🛜** (scan) dans l'interface.
2. Flask envoie la commande `SCAN` à l'Arduino par le port série.
3. L'Arduino lit la carte posée sur le lecteur et renvoie son **UID** (ex. `a3f2101b`).
4. Flask cherche dans la table `patients` la ligne dont l'`id` = cet UID.
5. Le patient est chargé en session → toutes les pages (RDV, dossier, vaccins…) l'utilisent.

> **Une carte = un patient.** L'UID de la carte est l'identifiant du patient en base.

---

## Branchement du lecteur RFID (RC522 → Arduino Uno)

| RC522 | Arduino |
|-------|---------|
| SDA   | D10     |
| SCK   | D13     |
| MOSI  | D11     |
| MISO  | D12     |
| RST   | D9      |
| GND   | GND     |
| 3.3V  | **3.3V** (pas 5V) |

Puis téléversez [SCAN/SCAN.ino](SCAN/SCAN.ino) avec l'IDE Arduino (bibliothèque **MFRC522** requise).

---

## Enregistrer une nouvelle carte patient

1. Récupérez l'UID de la carte : ouvrez le **moniteur série** Arduino (9600 bauds), tapez `SCAN`, posez la carte → l'UID s'affiche.
2. Utilisez cet UID comme `id` du patient dans MySQL :

```sql
INSERT INTO patients (id, civilite, nom, prenom, date_naissance, sexe, ...)
VALUES ('a3f2101b', 'Mr.', 'NOM', 'Prénom', '1990-01-01', 'M', ...);
```

C'est tout : au prochain scan, ce patient s'ouvrira.

---

## Installation

**1. Base de données** — lancez MySQL (MAMP), puis importez [database.sql](database.sql) (tables + un patient de démo) :

```bash
mysql -h 127.0.0.1 -P 8889 -u root -p < database.sql
```

Ou dans phpMyAdmin : onglet **Importer** → `database.sql`.
Connexion par défaut : `localhost:8889`, `root` / `root` (MAMP). Sinon, définissez `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`.

**2. Python**

```bash
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

**3. Port série** — trouvez le port de l'Arduino :

```bash
python -m serial.tools.list_ports
```

**4. Lancer** (en indiquant le port trouvé)

```bash
SERIAL_PORT=/dev/cu.usbmodemXXXX python app.py
```

Ouvrez http://127.0.0.1:5000 → posez la carte → cliquez sur **🛜**.

> **Pas d'Arduino ?** Lancez simplement `python app.py`, tapez `DEMO001` dans le champ ID puis cliquez sur **✓** : le patient de démo s'ouvre.

---

## Problèmes fréquents

| Message | Solution |
|---------|----------|
| `Port série non disponible` | Arduino non branché ou mauvais `SERIAL_PORT`. Fermez le moniteur série de l'IDE Arduino (il bloque le port). |
| `Nouvelle carte non détectée` | Posez la carte **avant** de cliquer, et laissez-la sur le lecteur. |
| `Aucun patient trouvé pour cette carte` | L'UID n'existe pas dans `patients.id` → enregistrez la carte (voir plus haut). |

---

## Structure

```
app.py            Serveur Flask + API (patients, RDV, consultations, vaccins, maladies, ordonnances)
SCAN/SCAN.ino     Code Arduino du lecteur RFID
database.sql      Tables MySQL + patient de démo
templates/        Pages HTML (patient, rdv, dossier_med, examens, suivi_medical, vaccins)
static/           CSS, photos, ordonnances générées (.docx)
```

> Les photos de patients et les ordonnances générées ne sont pas versionnées (données personnelles).
