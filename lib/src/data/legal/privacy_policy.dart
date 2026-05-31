String _getLastModified() {
  return "31.05.2026";
}

String get privacyPolicyDe => """
# Datenschutzerklärung

## 1. Allgemeine Hinweise
Der Schutz Ihrer personenbezogenen Daten ist uns ein wichtiges Anliegen. Die Nutzung dieser App ist grundsätzlich ohne Angabe personenbezogener Daten möglich.
Personenbezogene Daten werden ausschließlich im Rahmen der gesetzlichen Vorschriften, insbesondere der Datenschutz-Grundverordnung (DSGVO), verarbeitet.

Diese Datenschutzerklärung informiert Sie über Art, Umfang und Zweck der Verarbeitung personenbezogener Daten innerhalb der mobilen Anwendung.

## 2. Verantwortlicher
Verantwortlich im Sinne der DSGVO:

Gerrit Johann Schoo  
Studio Maximus  
Ansbacher Straße 35  
28215 Bremen  
Deutschland

E-Mail: studio.maximus69@gmail.com

## 3. Art und Zweck der Datenverarbeitung

### 3.1 Nutzung und Internetverbindung
Die App funktioniert für den Kernbetrieb (Lernen, Quizze, Prüfungen) vollständig offline.
Für Analysezwecke (siehe Abschnitt 5) werden jedoch anonymisierte Nutzungsdaten an Server von Google übertragen. Hierfür ist eine Internetverbindung erforderlich.

### 3.2 Abfrage des Bundeslandes
Zur Bereitstellung länderspezifischer Lerninhalte wird innerhalb der App das Bundesland abgefragt.

Diese Angabe erfolgt freiwillig.  
Sie dient ausschließlich der funktionalen Anpassung der Lerninhalte.  
Die Verarbeitung erfolgt ausschließlich lokal auf dem Endgerät.  
Eine Übermittlung an Dritte oder eine Verknüpfung mit anderen Daten findet nicht statt.

Rechtsgrundlage der Verarbeitung ist Art. 6 Abs. 1 lit. b DSGVO (Vertragserfüllung bzw. vorvertragliche Maßnahmen).

### 3.3 Lokale Speicherung
Alle innerhalb der App anfallenden Daten (z. B. Lernfortschritt, Testergebnisse, Einstellungen) werden ausschließlich lokal auf dem Endgerät des Nutzers gespeichert.

Es erfolgt keine externe Speicherung.  
Es erfolgt keine Sicherung in einer Cloud.  
Die Daten können jederzeit durch Deinstallation der App vollständig gelöscht werden.

## 4. In-App-Käufe und Abonnements
Die App bietet optionale In-App-Käufe an (Abonnement oder einmaliger Kauf), um zusätzliche Funktionen (Freischaltung von Probeprüfungen) zu aktivieren.

Die Abwicklung der Zahlung erfolgt ausschließlich über die jeweiligen App-Store-Anbieter (Google Play Store / Apple App Store).

Wir erhalten keine Zahlungsdaten, keine Rechnungsinformationen und keine personenbezogenen Abrechnungsdaten der Nutzer.

Es gelten insoweit die Datenschutzbestimmungen der jeweiligen Plattformbetreiber.

## 5. Firebase-Dienste (Google)

Diese App verwendet Dienste von **Firebase** (Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Irland).

### 5.1 Firebase Analytics

Firebase Analytics erfasst anonymisierte Nutzungsereignisse, darunter:

* App-Start und Sitzungsdauer
* Genutzte Funktionen (z. B. Quiz gestartet/beendet, Prüfung abgelegt, Lernmodus geöffnet)
* Kaufvorgänge (Anzeige der Kaufseite, Kaufabschluss)
* Eine pseudonyme App-Instanz-ID (kein Personenbezug)

### 5.2 Firebase Crashlytics

Firebase Crashlytics erfasst im Falle eines App-Absturzes automatisch technische Diagnosedaten, darunter:

* Stack-Trace des Fehlers
* Gerätetyp und Betriebssystemversion
* Zeitpunkt und Häufigkeit des Absturzes
* App-Version

Diese Daten enthalten **keine** personenbezogenen Informationen und dienen ausschließlich der Fehlerbehebung und Stabilitätsverbesserung der App.

### 5.3 Firebase Remote Config

Firebase Remote Config wird verwendet, um App-Einstellungen (z. B. Funktionsaktivierungen) ohne App-Update anpassen zu können. Es werden dabei **keine** personenbezogenen Daten erhoben oder übertragen.

### Gemeinsame Angaben zu allen Firebase-Diensten

**Zweck:** Verbesserung der App-Stabilität, Analyse der Nutzung und flexible Konfiguration.

**Rechtsgrundlage:** Art. 6 Abs. 1 lit. f DSGVO (berechtigte Interessen).

**Datenübertragung in Drittländer:** Google verarbeitet Daten auf Servern in den USA. Die Übermittlung erfolgt auf Grundlage der EU-Standardvertragsklauseln (Art. 46 DSGVO).

**Opt-out (Analytics & Crashlytics):**
**Android:** Einstellungen → Google → Werbung → Werbe-ID zurücksetzen oder Personalisierung deaktivieren

Weitere Informationen: [https://policies.google.com/privacy](https://policies.google.com/privacy)

## 6. Keine weiteren Drittanbieter
Abgesehen von Firebase (siehe Abschnitt 5) und den App-Store-Anbietern (Abschnitt 4) verwendet die App keine weiteren Drittanbieterdienste, insbesondere:

* Keine Werbenetzwerke
* Keine Social-Media-Plugins

## 7. Berechtigungen
Die App verlangt keine besonderen Zugriffsberechtigungen, insbesondere keinen Zugriff auf:

* Kontakte
* Kamera
* Mikrofon
* Standort
* Fotos oder Dateien
* Gerätekennungen

## 8. Minderjährige Nutzer
Die App richtet sich sowohl an Minderjährige als auch an volljährige Nutzer.
Die durch Firebase Analytics erfassten Daten sind pseudonymisiert und enthalten keinen direkten Personenbezug.

## 9. Rechte der betroffenen Personen
Soweit personenbezogene Daten verarbeitet werden, stehen den Betroffenen folgende Rechte zu:

* Recht auf Auskunft (Art. 15 DSGVO)
* Recht auf Berichtigung (Art. 16 DSGVO)
* Recht auf Löschung (Art. 17 DSGVO)
* Recht auf Einschränkung der Verarbeitung (Art. 18 DSGVO)
* Recht auf Widerspruch gegen die Verarbeitung (Art. 21 DSGVO)

Anfragen können jederzeit an die oben genannte E-Mail-Adresse gerichtet werden.

## 10. Änderung dieser Datenschutzerklärung
Wir behalten uns vor, diese Datenschutzerklärung anzupassen, sofern dies aufgrund geänderter rechtlicher Anforderungen oder technischer Änderungen der App erforderlich wird.

Diese Datenschutzerklärung unterliegt dem deutschen Recht.

Stand: ${_getLastModified()}
""";

String get privacyPolicyEn => """
# Privacy Policy

## 1. General Information
The protection of your personal data is an important concern for us. The use of this app is generally possible without providing personal data.
Personal data is processed exclusively within the scope of legal regulations, in particular the General Data Protection Regulation (GDPR).

This privacy policy informs you about the nature, scope, and purpose of the processing of personal data within the mobile application.

## 2. Controller
Controller within the meaning of the GDPR:
Gerrit Johann Schoo  
Studio Maximus  
Ansbacher Straße 35  
28215 Bremen  
Germany

Email: studio.maximus69@gmail.com

## 3. Type and Purpose of Data Processing

### 3.1 Use and Internet Connection
The app works completely offline for its core features (learning, quizzes, exams).
However, for analytics purposes (see Section 5), anonymized usage data is transmitted to Google's servers. An internet connection is required for this.

### 3.2 Query of the Federal State
To provide state-specific learning content, the federal state is requested within the app.

This information is provided voluntarily.  
It serves exclusively for the functional adaptation of the learning content.  
Processing takes place exclusively locally on the end device.  
Transmission to third parties or linking with other data does not take place.

The legal basis for processing is Art. 6 Para. 1 lit. b GDPR (performance of a contract or pre-contractual measures).

### 3.3 Local Storage
All data generated within the app (e.g., learning progress, test results, settings) are stored exclusively locally on the user's end device.

There is no external storage.  
There is no backup in a cloud.  
There is no backup in a cloud.
The data can be completely deleted at any time by uninstalling the app.

## 4. In-App Purchases and Subscriptions
The app offers optional in-app purchases (subscription or one-time purchase) to activate additional functions (unlocking practice exams).

Payment processing is carried out exclusively via the respective app store providers (Google Play Store / Apple App Store).

We do not receive any payment data, billing information, or personal billing data from users.

In this respect, the privacy policies of the respective platform operators apply.

## 5. Firebase Services (Google)

This app uses services provided by **Firebase** (Google Ireland Limited, Gordon House, Barrow Street, Dublin 4, Ireland).

### 5.1 Firebase Analytics

Firebase Analytics collects anonymized usage events, including:

* App launch and session duration
* Features used (e.g., quiz started/completed, exam taken, learning mode opened)
* Purchase events (paywall viewed, purchase completed)
* A pseudonymous app instance ID (no personal reference)

### 5.2 Firebase Crashlytics

Firebase Crashlytics automatically collects technical diagnostic data in the event of an app crash, including:

* Error stack trace
* Device type and operating system version
* Time and frequency of the crash
* App version

This data contains **no** personal information and is used exclusively for bug fixing and improving app stability.

### 5.3 Firebase Remote Config

Firebase Remote Config is used to adjust app settings (e.g., feature toggles) without releasing an app update. **No** personal data is collected or transmitted in this process.

### Common Information for All Firebase Services

**Purpose:** Improving app stability, analyzing usage, and flexible configuration.

**Legal basis:** Art. 6 Para. 1 lit. f GDPR (legitimate interests).

**Data transfer to third countries:** Google processes data on servers in the United States. The transfer is based on EU Standard Contractual Clauses (Art. 46 GDPR).

**Opt-out (Analytics & Crashlytics):**
**Android:** Settings → Google → Ads → Reset Advertising ID or disable personalization

For more information: [https://policies.google.com/privacy](https://policies.google.com/privacy)

## 6. No Further Third-Party Providers
Apart from Firebase (Section 5) and app store providers (Section 4), the app does not use any other third-party services, in particular:

* No advertising networks
* No social media plugins

## 7. Permissions
The app does not require any special access permissions, in particular no access to:

* Contacts
* Camera
* Microphone
* Location
* Photos or files
* Device identifiers

## 8. Minor Users
The app is aimed at both minors and adult users.
The data collected by Firebase Analytics is pseudonymized and does not contain any direct personal reference.

## 9. Rights of Data Subjects
Insofar as personal data is processed, data subjects have the following rights:

* Right of access (Art. 15 GDPR)
* Right to rectification (Art. 16 GDPR)
* Right to erasure (Art. 17 GDPR)
* Right to restriction of processing (Art. 18 GDPR)
* Right to object to processing (Art. 21 GDPR)

Inquiries can be sent to the email address mentioned above at any time.

## 10. Changes to this Privacy Policy
We reserve the right to adapt this privacy policy if this becomes necessary due to changed legal requirements or technical changes to the app.

This Privacy Policy is subject to German law.

Last updated: ${_getLastModified()}
""";
