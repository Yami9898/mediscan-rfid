# 🏥 eHealth — Patient record via RFID card

[🇫🇷 Français](README.md) | 🇬🇧 English

Web interface (Flask) that opens a **patient's medical record by scanning their RFID card**.
The doctor places the card on the reader → the record appears: identity, appointments, consultations, vaccines, chronic diseases, prescriptions.

---

## 💳 How it works: patient card → record

```
 Patient RFID card
        │  (card UID)
        ▼
 RC522 reader  ──SPI──►  Arduino  ──USB serial (9600 baud)──►  Flask (app.py)  ──►  MySQL
                                                                    │
                                                                    ▼
                                                       Patient record in the browser
```

1. The doctor clicks the **🛜** (scan) button in the interface.
2. Flask sends the `SCAN` command to the Arduino over the serial port.
3. The Arduino reads the card on the reader and sends back its **UID** (e.g. `a3f2101b`).
4. Flask looks up the row in the `patients` table whose `id` = that UID.
5. The patient is stored in the session → every page (appointments, record, vaccines…) uses it.

> 💡 **One card = one patient.** The card UID is the patient's ID in the database.

---

## 🔌 Wiring the RFID reader (RC522 → Arduino Uno)

| RC522 | Arduino |
|-------|---------|
| SDA   | D10     |
| SCK   | D13     |
| MOSI  | D11     |
| MISO  | D12     |
| RST   | D9      |
| GND   | GND     |
| 3.3V  | **3.3V** ⚠️ (not 5V) |

Then upload [SCAN/SCAN.ino](SCAN/SCAN.ino) with the Arduino IDE (**MFRC522** library required).

---

## 🪪 Registering a new patient card

1. Get the card UID: open the Arduino **Serial Monitor** (9600 baud), type `SCAN`, place the card → the UID is printed.
2. Use that UID as the patient's `id` in MySQL:

```sql
INSERT INTO patients (id, civilite, nom, prenom, date_naissance, sexe, ...)
VALUES ('a3f2101b', 'Mr.', 'LASTNAME', 'Firstname', '1990-01-01', 'M', ...);
```

That's it: the next scan opens this patient.

---

## 🚀 Setup

**1. Database** — start MySQL (MAMP), then import [database.sql](database.sql) (tables + one demo patient):

```bash
mysql -h 127.0.0.1 -P 8889 -u root -p < database.sql
```

Or in phpMyAdmin: **Import** tab → `database.sql`.
Default connection: `localhost:8889`, `root` / `root` (MAMP). Otherwise set `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`.

**2. Python**

```bash
python3 -m venv env
source env/bin/activate
pip install -r requirements.txt
```

**3. Serial port** — find the Arduino's port:

```bash
python -m serial.tools.list_ports
```

**4. Run** (with the port you found)

```bash
SERIAL_PORT=/dev/cu.usbmodemXXXX python app.py
```

Open http://127.0.0.1:5000 → place the card → click **🛜**. ✅

> 🧪 **No Arduino?** Just run `python app.py`, type `DEMO001` in the ID field and click **✓**: the demo patient opens.

---

## 🛠️ Troubleshooting

The app's messages are in French:

| Message | Fix |
|---------|-----|
| `Port série non disponible` (serial port unavailable) | Arduino not plugged in or wrong `SERIAL_PORT`. Close the Arduino IDE Serial Monitor (it locks the port). |
| `Nouvelle carte non détectée` (no new card detected) | Place the card **before** clicking, and leave it on the reader. |
| `Aucun patient trouvé pour cette carte` (no patient for this card) | The UID isn't in `patients.id` → register the card (see above). |

---

## 📁 Structure

```
app.py            Flask server + API (patients, appointments, consultations, vaccines, diseases, prescriptions)
SCAN/SCAN.ino     Arduino code for the RFID reader
database.sql      MySQL tables + demo patient
templates/        HTML pages (patient, rdv, dossier_med, examens, suivi_medical, vaccins)
static/           CSS, photos, generated prescriptions (.docx)
```

> 🔒 Patient photos and generated prescriptions are not versioned (personal data).
