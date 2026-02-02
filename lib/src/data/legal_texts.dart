
import 'package:flutter/material.dart';
import 'legal/imprint.dart';
import 'legal/privacy_policy.dart';

class LegalTexts {
  static String getPrivacyPolicy(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'de') {
      return privacyPolicyDe;
    }
    return privacyPolicyEn;
  }

  static String getImprint(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'de') {
      return imprintDe;
    }
    return imprintEn;
  }

  static String getDisclaimer(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == 'de') {
      return _disclaimerDe;
    }
    return _disclaimerEn;
  }

  static const String _disclaimerDe = """
**Keine staatliche Verbindung**

Diese App ist ein privates Projekt und steht **nicht** in Verbindung mit dem Bundesamt für Migration und Flüchtlinge (BAMF) oder einer anderen staatlichen Stelle.

Die Fragen basieren auf dem offiziellen Katalog, dienen aber nur zu Übungszwecken.

Es besteht kein Anspruch auf Richtigkeit oder Vollständigkeit im Vergleich zur amtlichen Prüfung.

Webseite des BAMF:
[https://www.bamf.de](https://www.bamf.de)
""";

  static const String _disclaimerEn = """
**No Government Affiliation**

This app is a private project and is **not** affiliated with the Federal Office for Migration and Refugees (BAMF) or any other government agency.

The questions are based on the official catalog but are for practice purposes only.

No guarantee is made regarding accuracy or completeness compared to the official examination.

BAMF website:
[https://www.bamf.de](https://www.bamf.de)
""";
}
