#!/usr/bin/env python3
"""Holt den Betriebsstand von Aurora aus allen Quellen an einen Ort.

Warum es das gibt: Die Frage „laeuft das eigentlich?" war bis hierher nur
durch Klicken durch vier Oberflaechen zu beantworten — Play Console,
Firebase-Console, GitHub, Firestore-REST. Und die wichtigste Quelle antwortet
mit Tagen Verzug, was beim Klicken niemand sieht.

Zwei Ausgaben, ein Lauf:
  * Eine Zusammenfassung im Terminal fuer Menschen.
  * Eine JSON-Datei fuer Werkzeuge und Sprachmodelle, die den Stand in einem
    Zug lesen sollen statt in zwanzig Aufrufen.

**Jede Zahl traegt ihr Stand-Datum.** Das ist keine Zierde: Die
Versionsverteilung von Play hinkt regelmaessig fuenf Tage nach. Eine Anzeige
„39 Geraete" ohne „Stand 07.08." erzeugt genau den Irrtum, aus dem dieses
Skript entstanden ist.

Faellt eine Quelle aus, bricht der Lauf nicht ab. Sie meldet im Klartext, was
fehlt und was dagegen zu tun ist — der erste Lauf ist damit zugleich die
Diagnose.

Datenschutz: Die Ausgabedatei liegt **ausserhalb des Arbeitsbaums**
(~/.config/aurora-status/), damit sie kein Schnitt und kein `git add -f`
versehentlich in ein oeffentliches Repo traegt. Freitexte aus dem Feedback
sind Gesundheitsdaten nach DSGVO Art. 9 und werden nur mit `--texte` geholt;
ohne das Flag kommen ausschliesslich Namen und Zeitpunkte
(`mask.fieldPaths=__name__`).

Beispiele:
    python tool/aurora_status.py
    python tool/aurora_status.py --texte
    python tool/aurora_status.py --key ~/.config/play-console/aurora-play-sa.json
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import os
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

PACKAGE_NAME = "com.disapp.dis_app"
DEVELOPER_ID = "6785276662525223500"
FIREBASE_PROJECT = "auroa-7f66b"
GITHUB_REPO = "Reffn/Aurora"

REPORTS_BUCKET = f"pubsite_prod_{DEVELOPER_ID}"
REPORTS_PREFIX = "stats/installs/"

SCOPES = [
    "https://www.googleapis.com/auth/androidpublisher",
    "https://www.googleapis.com/auth/devstorage.read_only",
]

DEFAULT_OUTPUT = Path.home() / ".config" / "aurora-status" / "status.json"

# Ohne diese Angabe antwortet die Firestore-REST-Schnittstelle fuer das
# Standardprojekt der lokalen gcloud-Konfiguration — und das ist hier ein
# anderes.
FIRESTORE_COLLECTIONS = ("feedback", "telemetry")


def log(text: str) -> None:
    print(text, file=sys.stderr)


def quelle(name: str, ok: bool, **felder: object) -> dict:
    return {"quelle": name, "ok": ok, **felder}


# --------------------------------------------------------------------------
# Play: was gerade wirklich ausgeliefert wird (ohne Verzug)
# --------------------------------------------------------------------------


def play_tracks(key_path: Path) -> dict:
    """Liest die Tracks ueber die Publisher-API.

    Diese Quelle ist die einzige ohne Verzug: Sie sagt, welcher Versionscode
    in welchem Kanal steht und bei wie viel Prozent der Rollout haengt. Dazu
    wird ein Edit angelegt und sofort wieder verworfen — derselbe Weg, den
    `play_upload.py --dry-run` geht.
    """
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        credentials = service_account.Credentials.from_service_account_file(
            str(key_path), scopes=SCOPES
        )
        service = build(
            "androidpublisher", "v3", credentials=credentials, cache_discovery=False
        )
        edits = service.edits()
        edit_id = edits.insert(body={}, packageName=PACKAGE_NAME).execute()["id"]
        try:
            antwort = edits.tracks().list(
                packageName=PACKAGE_NAME, editId=edit_id
            ).execute()
        finally:
            # Der Edit wird immer verworfen, auch wenn das Lesen scheitert —
            # ein offener Edit blockiert spaetere Uploads.
            edits.delete(packageName=PACKAGE_NAME, editId=edit_id).execute()

        spuren = []
        for track in antwort.get("tracks", []):
            for release in track.get("releases", []):
                spuren.append(
                    {
                        "kanal": track.get("track"),
                        "versionscodes": release.get("versionCodes", []),
                        "name": release.get("name"),
                        "status": release.get("status"),
                        "anteil": release.get("userFraction"),
                    }
                )

        return quelle(
            "play_tracks",
            True,
            stand="jetzt (kein Verzug)",
            spuren=spuren,
        )
    except Exception as fehler:  # noqa: BLE001 — jede Quelle meldet selbst
        return quelle(
            "play_tracks",
            False,
            fehler=str(fehler),
            hinweis=(
                "Schluessel pruefen (PLAY_SERVICE_ACCOUNT_JSON oder --key). "
                "Das Dienstkonto braucht in der Play Console Zugriff auf die App."
            ),
        )


# --------------------------------------------------------------------------
# Play: Installationsstatistik aus dem Berichts-Bucket (mit Verzug)
# --------------------------------------------------------------------------


def _lies_csv(rohdaten: bytes) -> list[dict]:
    """Play liefert diese Berichte als UTF-16.

    Als UTF-8 gelesen kommt Unsinn heraus, ohne dass irgendetwas scheitert —
    deshalb wird die Kodierung geprueft und nicht angenommen.
    """
    for kodierung in ("utf-16", "utf-8-sig", "utf-8"):
        try:
            text = rohdaten.decode(kodierung)
        except UnicodeDecodeError:
            continue
        if "," in text.splitlines()[0] if text.splitlines() else False:
            return list(csv.DictReader(io.StringIO(text)))
    return []


def _bucket_sitzung(key_path: Path):
    from google.auth.transport.requests import AuthorizedSession
    from google.oauth2 import service_account

    credentials = service_account.Credentials.from_service_account_file(
        str(key_path), scopes=SCOPES
    )
    return AuthorizedSession(credentials)


def _bucket_dateien(session, prefix: str) -> list[str]:
    namen: list[str] = []
    token = None
    while True:
        params: dict[str, object] = {"prefix": prefix, "maxResults": 1000}
        if token:
            params["pageToken"] = token
        antwort = session.get(
            f"https://storage.googleapis.com/storage/v1/b/{REPORTS_BUCKET}/o",
            params=params,
            timeout=60,
        )
        antwort.raise_for_status()
        daten = antwort.json()
        namen += [o["name"] for o in daten.get("items", [])]
        token = daten.get("nextPageToken")
        if not token:
            return sorted(namen)


def _bucket_csv(session, name: str) -> list[dict]:
    antwort = session.get(
        f"https://storage.googleapis.com/storage/v1/b/{REPORTS_BUCKET}"
        f"/o/{name.replace('/', '%2F')}",
        params={"alt": "media"},
        timeout=120,
    )
    antwort.raise_for_status()
    return _lies_csv(antwort.content)


def _zahl(zeile: dict, spalte: str) -> int:
    try:
        return int(zeile.get(spalte) or 0)
    except ValueError:
        return 0


def play_installationen(key_path: Path) -> dict:
    """Holt den juengsten Versions-Bericht aus dem Cloud-Storage-Bucket."""
    try:
        session = _bucket_sitzung(key_path)

        liste = session.get(
            f"https://storage.googleapis.com/storage/v1/b/{REPORTS_BUCKET}/o",
            params={"prefix": f"{REPORTS_PREFIX}installs_{PACKAGE_NAME}_"},
            timeout=60,
        )
        if liste.status_code == 403:
            return quelle(
                "play_installationen",
                False,
                fehler="403 — kein Zugriff auf den Berichts-Bucket",
                hinweis=(
                    "Play Console → Nutzer und Berechtigungen → das Dienstkonto "
                    "einladen mit „App-Informationen ansehen und Bulk-Berichte "
                    "herunterladen“. Der Bucket-Zugriff wird dort vergeben, "
                    "nicht in der Cloud Console."
                ),
            )
        liste.raise_for_status()

        objekte = liste.json().get("items", [])
        versions_dateien = sorted(
            (o for o in objekte if o["name"].endswith("_app_version.csv")),
            key=lambda o: o["name"],
        )
        if not versions_dateien:
            return quelle(
                "play_installationen",
                False,
                fehler="Keine Versions-Berichte im Bucket",
                hinweis=f"Gesucht unter gs://{REPORTS_BUCKET}/{REPORTS_PREFIX}",
            )

        juengste = versions_dateien[-1]
        inhalt = session.get(
            f"https://storage.googleapis.com/storage/v1/b/{REPORTS_BUCKET}"
            f"/o/{juengste['name'].replace('/', '%2F')}",
            params={"alt": "media"},
            timeout=120,
        )
        inhalt.raise_for_status()

        zeilen = _lies_csv(inhalt.content)
        if not zeilen:
            return quelle(
                "play_installationen",
                False,
                fehler="Bericht liess sich nicht lesen",
                hinweis="Kodierung pruefen — Play liefert diese Dateien als UTF-16.",
            )

        datums_spalte = next(
            (s for s in zeilen[0] if s.strip().lower() == "date"), None
        )
        letzter_tag = max(z[datums_spalte] for z in zeilen) if datums_spalte else None

        aktive_spalte = next(
            (s for s in zeilen[0] if "active device installs" in s.strip().lower()),
            None,
        )
        version_spalte = next(
            (s for s in zeilen[0] if "version code" in s.strip().lower()), None
        )

        je_version: dict[str, int] = defaultdict(int)
        if letzter_tag and aktive_spalte and version_spalte:
            for zeile in zeilen:
                if zeile.get(datums_spalte) != letzter_tag:
                    continue
                try:
                    je_version[zeile[version_spalte]] += int(
                        zeile[aktive_spalte] or 0
                    )
                except ValueError:
                    continue

        return quelle(
            "play_installationen",
            True,
            stand=letzter_tag,
            bericht=juengste["name"],
            aktive_geraete_gesamt=sum(je_version.values()) or None,
            aktive_geraete_je_versionscode=dict(sorted(je_version.items())),
            warnung=(
                "Diese Zahlen hinken der Wirklichkeit mehrere Tage nach. "
                "Das Stand-Datum ist Teil der Aussage."
            ),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("play_installationen", False, fehler=str(fehler))


def play_bestand(key_path: Path) -> dict:
    """Installationen, Deinstallationen und Bestand aus dem Uebersichtsbericht.

    Die haerteste Zahl der ganzen Sammlung steht hier: wie viele die App
    wieder loeschen. Das beantwortet „haelt das im Alltag?" ehrlicher als
    jede Installationszahl.

    **Die richtige Spalte ist `Daily User Uninstalls`, nicht `Daily Device
    Uninstalls`.** Letztere laesst Play in diesen Berichten durchgaengig auf
    null stehen — am 13.08.2026 nachgezaehlt: 100 Geraete-Installationen,
    0 Geraete-Deinstallationen, aber 92 Nutzer-Installationen und 60
    Nutzer-Deinstallationen. Wer die Geraete-Spalte nimmt, berichtet eine
    Null, die nach „niemand loescht die App" aussieht und das Gegenteil
    verschweigt.

    `Active Device Installs` ist ein **Bestand**, keine Bewegung: Die Spalte
    wird nicht summiert, sondern es zaehlt der letzte Tag mit Wert.
    """
    try:
        session = _bucket_sitzung(key_path)
        dateien = _bucket_dateien(
            session, f"{REPORTS_PREFIX}installs_{PACKAGE_NAME}_"
        )
        uebersichten = [d for d in dateien if d.endswith("_overview.csv")]
        if not uebersichten:
            return quelle("play_bestand", False, fehler="Kein Uebersichtsbericht")

        installiert = deinstalliert = 0
        letzte_zeile: dict = {}
        for datei in uebersichten:
            for zeile in _bucket_csv(session, datei):
                installiert += _zahl(zeile, "Daily User Installs")
                deinstalliert += _zahl(zeile, "Daily User Uninstalls")
                if _zahl(zeile, "Active Device Installs"):
                    letzte_zeile = zeile

        aktiv = _zahl(letzte_zeile, "Active Device Installs") or None
        geblieben = (
            round(100 * (installiert - deinstalliert) / installiert)
            if installiert
            else None
        )

        return quelle(
            "play_bestand",
            True,
            stand=letzte_zeile.get("Date"),
            zeitraum=f"{uebersichten[0][-19:-13]} bis {uebersichten[-1][-19:-13]}",
            installationen_gesamt=installiert,
            deinstallationen_gesamt=deinstalliert,
            geblieben_prozent=geblieben,
            aktive_geraete=aktiv,
            warnung="Hinkt mehrere Tage nach — das Stand-Datum gehoert zur Zahl.",
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("play_bestand", False, fehler=str(fehler))


def play_store_besucher(key_path: Path) -> dict:
    """Wie viele den Store-Eintrag ueberhaupt sehen — und wie viele bleiben.

    Diese Quelle beantwortet als einzige die Frage, ob Bewerbung etwas
    braechte: Ohne Besucher hilft kein besserer Eintrag, und ohne Conversion
    hilft kein Besucher.
    """
    try:
        session = _bucket_sitzung(key_path)
        dateien = [
            d
            for d in _bucket_dateien(session, "stats/store_performance/")
            if d.endswith("_country.csv")
        ]
        if not dateien:
            return quelle("play_store_besucher", False, fehler="Keine Berichte")

        je_monat: dict[str, dict[str, int]] = {}
        for datei in dateien:
            monat = datei[-18:-12]
            for zeile in _bucket_csv(session, datei):
                eintrag = je_monat.setdefault(
                    zeile.get("Date", monat)[:7], {"besucher": 0, "installiert": 0}
                )
                eintrag["besucher"] += _zahl(zeile, "Store listing visitors")
                eintrag["installiert"] += _zahl(zeile, "Store listing acquisitions")

        besucher = sum(m["besucher"] for m in je_monat.values())
        installiert = sum(m["installiert"] for m in je_monat.values())

        # Woher die Leute kommen — Suche, Play-Vorschlaege oder ein Link von
        # aussen. Fuer die Frage, ob Bewerbung etwas braechte, ist das die
        # aussagekraeftigste Aufschluesselung im ganzen Bucket: Sie
        # unterscheidet „niemand sucht danach" von „niemand kennt es".
        je_herkunft: dict[str, int] = defaultdict(int)
        for datei in [
            d
            for d in _bucket_dateien(session, "stats/store_performance/")
            if d.endswith("_source.csv")
        ]:
            for zeile in _bucket_csv(session, datei):
                dimension = next(
                    (
                        wert
                        for spalte, wert in zeile.items()
                        if spalte not in ("Date", "Package name")
                        and not spalte.startswith("Store listing")
                    ),
                    "unbekannt",
                )
                je_herkunft[dimension or "unbekannt"] += _zahl(
                    zeile, "Store listing visitors"
                )

        return quelle(
            "play_store_besucher",
            True,
            stand=max(je_monat) if je_monat else None,
            besucher_gesamt=besucher,
            installationen_gesamt=installiert,
            besucher_je_herkunft=dict(
                sorted(je_herkunft.items(), key=lambda p: -p[1])
            ),
            # Am 13.08.2026 stand ueber alle elf Monate ausschliesslich
            # „Other" in der Spalte `Traffic source`. Play weist Suche,
            # Vorschlaege und fremde Verweise erst ab einem Schwellwert
            # getrennt aus — darunter ist die Aufschluesselung selbst der
            # Befund: zu wenig Verkehr, um ueberhaupt sortiert zu werden.
            herkunft_aussagekraeftig=bool(
                set(je_herkunft) - {"Other", "unbekannt", ""}
            ),
            je_monat=dict(sorted(je_monat.items())),
            warnung=(
                "Besucher heisst: jemand hat die Store-Seite geoeffnet. "
                "Diese Zahl misst Sichtbarkeit, nicht Qualitaet."
            ),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("play_store_besucher", False, fehler=str(fehler))


def play_vitals(key_path: Path) -> dict:
    """Absturz- und ANR-Rate ueber die Reporting-API.

    Diese Quelle ist deutlich frischer als die Berichte im Bucket: Am
    13.08.2026 reichten die CSVs bis zum 4. August, die Vitals bis zum 12.
    Sie beantwortet als einzige die Frage, die hinter „92 installiert, 60
    wieder geloescht" steht — ob die App auf fremden Geraeten ueberhaupt
    laeuft.

    Der Zeitraum wird nicht geraten: Die Schnittstelle nennt selbst, bis
    wann sie Daten hat (`freshnessInfo`), und eine Anfrage darueber hinaus
    wird mit 400 abgewiesen.
    """
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        credentials = service_account.Credentials.from_service_account_file(
            str(key_path),
            scopes=["https://www.googleapis.com/auth/playdeveloperreporting"],
        )
        service = build(
            "playdeveloperreporting",
            "v1beta1",
            credentials=credentials,
            cache_discovery=False,
        )

        ergebnisse: dict[str, object] = {}
        for schluessel, zweig, metrikensatz, metriken in (
            (
                "abstuerze",
                "crashrate",
                "crashRateMetricSet",
                ["crashRate", "distinctUsers"],
            ),
            ("anr", "anrrate", "anrRateMetricSet", ["anrRate", "distinctUsers"]),
        ):
            name = f"apps/{PACKAGE_NAME}/{metrikensatz}"
            try:
                info = getattr(service.vitals(), zweig)().get(name=name).execute()
                frisch = next(
                    (
                        f["latestEndTime"]
                        for f in info.get("freshnessInfo", {}).get("freshnesses", [])
                        if f.get("aggregationPeriod") == "DAILY"
                    ),
                    None,
                )
                if not frisch:
                    ergebnisse[schluessel] = {"ok": False, "fehler": "keine Freshness"}
                    continue

                ende = {
                    "year": frisch["year"],
                    "month": frisch["month"],
                    "day": frisch["day"],
                }
                start = dict(ende)
                start["day"] = 1

                antwort = (
                    getattr(service.vitals(), zweig)()
                    .query(
                        name=name,
                        body={
                            "timelineSpec": {
                                "aggregationPeriod": "DAILY",
                                "startTime": start,
                                "endTime": ende,
                            },
                            "metrics": metriken,
                        },
                    )
                    .execute()
                )
                reihen = antwort.get("rows", [])
                werte = []
                for reihe in reihen:
                    eintrag = {
                        m["metric"]: m.get("decimalValue", {}).get("value")
                        or m.get("decimalValue")
                        for m in reihe.get("metrics", [])
                    }
                    zeitpunkt = reihe.get("startTime", {})
                    eintrag["tag"] = (
                        f"{zeitpunkt.get('year')}-{zeitpunkt.get('month'):02d}"
                        f"-{zeitpunkt.get('day'):02d}"
                        if zeitpunkt.get("year")
                        else None
                    )
                    werte.append(eintrag)

                ergebnisse[schluessel] = {
                    "ok": True,
                    "stand": f"{ende['year']}-{ende['month']:02d}-{ende['day']:02d}",
                    "tage_mit_daten": len(werte),
                    "verlauf": werte,
                }
            except Exception as innen:  # noqa: BLE001
                ergebnisse[schluessel] = {"ok": False, "fehler": str(innen)[:200]}

        return quelle(
            "play_vitals",
            any(e.get("ok") for e in ergebnisse.values()),
            stand=next(
                (e.get("stand") for e in ergebnisse.values() if e.get("ok")), None
            ),
            **ergebnisse,
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle(
            "play_vitals",
            False,
            fehler=str(fehler),
            hinweis=(
                "Bei 403 „has not been used in project“: "
                "gcloud services enable playdeveloperreporting.googleapis.com "
                f"--project={FIREBASE_PROJECT}"
            ),
        )


def play_android_versionen(key_path: Path) -> dict:
    """Auf welchen Android-Fassungen die App laeuft — Grundlage fuer minSdk."""
    try:
        session = _bucket_sitzung(key_path)
        dateien = [
            d
            for d in _bucket_dateien(
                session, f"{REPORTS_PREFIX}installs_{PACKAGE_NAME}_"
            )
            if d.endswith("_os_version.csv")
        ]
        if not dateien:
            return quelle("play_android_versionen", False, fehler="Keine Berichte")

        zeilen = _bucket_csv(session, dateien[-1])
        if not zeilen:
            return quelle("play_android_versionen", False, fehler="Nicht lesbar")

        letzter_tag = max(z.get("Date", "") for z in zeilen)
        je_os: dict[str, int] = defaultdict(int)
        for zeile in zeilen:
            if zeile.get("Date") != letzter_tag:
                continue
            bestand = _zahl(zeile, "Active Device Installs")
            if bestand:
                je_os[zeile.get("Android OS Version", "?")] += bestand

        return quelle(
            "play_android_versionen",
            True,
            stand=letzter_tag,
            aktive_geraete_je_os=dict(sorted(je_os.items(), key=lambda p: -p[1])),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("play_android_versionen", False, fehler=str(fehler))


def app_check_verkehr() -> dict:
    """Wie viele Anfragen App Check bestaetigt — und wie viele nicht.

    Der Wert ist nicht die Sicherheitslage, sondern der Beweis, dass echter
    Verkehr aus dem Store ankommt: `security = VALID` gibt es nur aus einer
    Play-Installation, seitlich geladene Bauten liefern `INVALID`.
    """
    try:
        import requests

        token = _gcloud_token()
        ende = datetime.now(timezone.utc)
        start = ende.replace(hour=0, minute=0, second=0, microsecond=0)
        antwort = requests.get(
            f"https://monitoring.googleapis.com/v3/projects/{FIREBASE_PROJECT}"
            "/timeSeries",
            headers={"Authorization": f"Bearer {token}"},
            params={
                "filter": (
                    'metric.type="firebaseappcheck.googleapis.com/'
                    'services/verdict_count"'
                ),
                "interval.startTime": (
                    start.replace(day=1).isoformat().replace("+00:00", "Z")
                ),
                "interval.endTime": ende.isoformat().replace("+00:00", "Z"),
                "aggregation.alignmentPeriod": "86400s",
                "aggregation.perSeriesAligner": "ALIGN_SUM",
            },
            timeout=60,
        )
        if antwort.status_code != 200:
            return quelle(
                "app_check_verkehr",
                False,
                fehler=f"{antwort.status_code}: {antwort.text[:200]}",
            )

        je_urteil: dict[str, int] = defaultdict(int)
        for reihe in antwort.json().get("timeSeries", []):
            urteil = reihe.get("metric", {}).get("labels", {}).get("security", "?")
            for punkt in reihe.get("points", []):
                je_urteil[urteil] += int(punkt["value"].get("int64Value", 0))

        return quelle(
            "app_check_verkehr",
            True,
            stand="dieser Monat",
            pruefungen_je_urteil=dict(je_urteil),
            hinweis=(
                "VALID kommt nur aus Play-Installationen. INVALID sind in der "
                "Regel eigene, seitlich geladene Testlaeufe."
            ),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("app_check_verkehr", False, fehler=str(fehler))


def github_ci() -> dict:
    """Laeuft die Prüfstrecke, und wann zuletzt gruen?"""
    try:
        ergebnis = subprocess.run(
            [
                "gh",
                "api",
                f"repos/{GITHUB_REPO}/actions/runs?per_page=10",
                "--jq",
                "[.workflow_runs[] | {name:.name,zweig:.head_branch,"
                "ergebnis:.conclusion,zeit:.created_at}]",
            ],
            capture_output=True,
            text=True,
            check=True,
            shell=os.name == "nt",
        )
        laeufe = json.loads(ergebnis.stdout)
        return quelle(
            "github_ci",
            True,
            stand="jetzt (kein Verzug)",
            anzahl=len(laeufe),
            letzte=laeufe[:5],
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("github_ci", False, fehler=str(fehler)[:200])


def webseite() -> dict:
    """Erreichbarkeit — und die Abnahmezeile aus website/README.md.

    Auf der Seite stand einmal „Kein Tracking, keine Analytics" waehrend sie
    Google Analytics nachlud. Gefunden hat das nur eine Messung. Deshalb
    zaehlt hier nicht der Quelltext, sondern was ausgeliefert wird.
    """
    import re

    try:
        import requests

        ergebnisse = {}
        for adresse in ("https://3ofus.app", "https://auroa-7f66b.web.app"):
            try:
                antwort = requests.get(adresse, timeout=30)
                fremde = sorted(
                    {
                        treffer
                        for treffer in re.findall(
                            r'https?://([a-z0-9.-]+)', antwort.text
                        )
                        if not treffer.endswith(("3ofus.app", "web.app", "w3.org"))
                    }
                )
                ergebnisse[adresse] = {
                    "status": antwort.status_code,
                    "fremde_hosts": fremde,
                }
            except Exception as innen:  # noqa: BLE001
                ergebnisse[adresse] = {"fehler": str(innen)[:150]}

        return quelle(
            "webseite",
            True,
            stand="jetzt (kein Verzug)",
            seiten=ergebnisse,
            hinweis=(
                "Fremde Hosts im ausgelieferten HTML. Leer ist das Ziel — "
                "am 12.08.2026 waren es vier, danach null."
            ),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("webseite", False, fehler=str(fehler)[:200])


def play_rezensionen(key_path: Path) -> dict:
    """Rezensionen im Store — die einzige Rueckmeldung, die ohne Zutun kommt.

    Steht die Zahl auf null, ist das ein Befund und keine Leerstelle: Dann
    gibt es kein Store-Feedback, und man muss nicht danach suchen.
    """
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build

        credentials = service_account.Credentials.from_service_account_file(
            str(key_path), scopes=SCOPES
        )
        service = build(
            "androidpublisher", "v3", credentials=credentials, cache_discovery=False
        )
        antwort = service.reviews().list(
            packageName=PACKAGE_NAME, maxResults=100
        ).execute()

        rezensionen = []
        for eintrag in antwort.get("reviews", []):
            kommentar = (eintrag.get("comments") or [{}])[0].get("userComment", {})
            rezensionen.append(
                {
                    "sterne": kommentar.get("starRating"),
                    "text": kommentar.get("text"),
                    "fassung": kommentar.get("appVersionName"),
                    "zeit": kommentar.get("lastModified", {}).get("seconds"),
                }
            )

        return quelle(
            "play_rezensionen",
            True,
            stand="jetzt (kein Verzug)",
            anzahl=len(rezensionen),
            rezensionen=rezensionen,
            hinweis=(
                "Die Schnittstelle liefert nur Rezensionen der letzten Woche."
                if not rezensionen
                else None
            ),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("play_rezensionen", False, fehler=str(fehler))


# --------------------------------------------------------------------------
# Firestore: was aus dem Feld angekommen ist
# --------------------------------------------------------------------------


def _gcloud_token() -> str:
    ergebnis = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        capture_output=True,
        text=True,
        check=True,
        shell=os.name == "nt",
    )
    return ergebnis.stdout.strip()


def firestore(mit_texten: bool) -> dict:
    """Zaehlt die Dokumente in `feedback` und `telemetry`.

    Die beiden Sammlungen werden **verschieden** behandelt, und das ist keine
    Bequemlichkeit, sondern folgt ihrem Inhalt:

    * `feedback` traegt Freitexte, die jemand mit DIS geschrieben hat — nach
      DSGVO Art. 9 Gesundheitsdaten. Ohne `--texte` kommen ueber
      `mask.fieldPaths=__name__` nur Name und Zeitpunkt.
    * `telemetry` traegt per Konstruktion keinen Freitext: Ereignisname, Tag,
      App-Version, sonst nichts — keine Kennung, kein Zaehler, keine Sitzung.
      Das ist die Zusage, auf der die Einwilligung beruht. Diese Felder
      koennen deshalb immer geholt werden, und sie beantworten die Frage, fuer
      die es die Sammlung gibt: Auf welcher Fassung laeuft das eigentlich?
    """
    try:
        import requests

        token = _gcloud_token()
        basis = (
            f"https://firestore.googleapis.com/v1/projects/{FIREBASE_PROJECT}"
            "/databases/(default)/documents"
        )
        kopf = {"Authorization": f"Bearer {token}"}

        sammlungen: dict[str, object] = {}
        for name in FIRESTORE_COLLECTIONS:
            params: dict[str, object] = {"pageSize": 300}
            felder_holen = mit_texten or name == "telemetry"
            if not felder_holen:
                params["mask.fieldPaths"] = "__name__"

            antwort = requests.get(
                f"{basis}/{name}", headers=kopf, params=params, timeout=60
            )
            if antwort.status_code != 200:
                sammlungen[name] = {
                    "ok": False,
                    "fehler": f"{antwort.status_code}: {antwort.text[:200]}",
                }
                continue

            dokumente = antwort.json().get("documents", [])
            eintraege = [
                {
                    "id": d["name"].rsplit("/", 1)[-1],
                    "angelegt": d.get("createTime"),
                    **({"felder": d.get("fields", {})} if felder_holen else {}),
                }
                for d in dokumente
            ]
            eintraege.sort(key=lambda e: e["angelegt"] or "")

            werte: dict[str, object] = {
                "ok": True,
                "anzahl": len(eintraege),
                "juengster": eintraege[-1]["angelegt"] if eintraege else None,
                "eintraege": eintraege,
            }

            # Die Frage, fuer die es die Telemetrie gibt: Auf welcher Fassung
            # laeuft das im Feld? Ohne Verzug, im Gegensatz zur
            # Play-Statistik.
            if name == "telemetry":
                je_version: dict[str, int] = defaultdict(int)
                for eintrag in eintraege:
                    version = (
                        eintrag.get("felder", {})
                        .get("appVersion", {})
                        .get("stringValue")
                    )
                    je_version[version or "unbekannt"] += 1
                werte["ereignisse_je_version"] = dict(sorted(je_version.items()))

            sammlungen[name] = werte

        return quelle(
            "firestore",
            True,
            stand="jetzt (kein Verzug)",
            texte_enthalten=mit_texten,
            sammlungen=sammlungen,
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle(
            "firestore",
            False,
            fehler=str(fehler),
            hinweis=(
                "`gcloud auth login` noetig? Der Zugriff laeuft ueber das "
                "angemeldete Konto, nicht ueber das Play-Dienstkonto."
            ),
        )


# --------------------------------------------------------------------------
# GitHub
# --------------------------------------------------------------------------


def github() -> dict:
    try:
        ergebnis = subprocess.run(
            [
                "gh",
                "api",
                f"repos/{GITHUB_REPO}",
                "--jq",
                "{privat:.private,sterne:.stargazers_count,forks:.forks_count,"
                "offene_issues:.open_issues_count,letzter_push:.pushed_at}",
            ],
            capture_output=True,
            text=True,
            check=True,
            shell=os.name == "nt",
        )
        return quelle(
            "github",
            True,
            stand="jetzt (kein Verzug)",
            repo=GITHUB_REPO,
            **json.loads(ergebnis.stdout),
        )
    except Exception as fehler:  # noqa: BLE001
        return quelle("github", False, fehler=str(fehler), hinweis="`gh auth login`?")


# --------------------------------------------------------------------------


def zusammenfassung(bericht: dict) -> str:
    zeilen = [f"Aurora — Stand {bericht['erstellt']}", ""]

    for eintrag in bericht["quellen"]:
        name = eintrag["quelle"]
        if not eintrag["ok"]:
            zeilen.append(f"  ✗ {name}: {eintrag.get('fehler', 'unbekannt')}")
            if eintrag.get("hinweis"):
                zeilen.append(f"      → {eintrag['hinweis']}")
            continue

        if name == "play_tracks":
            for spur in eintrag["spuren"]:
                anteil = spur.get("anteil")
                prozent = f"{float(anteil) * 100:.0f} %" if anteil else "100 %"
                zeilen.append(
                    f"  ✓ Play-Kanal {spur['kanal']}: "
                    f"{spur['name']} (Code {spur['versionscodes']}), "
                    f"{spur['status']}, {prozent}"
                )
        elif name == "play_bestand":
            zeilen.append(
                f"  ✓ Bestand: {eintrag.get('aktive_geraete')} aktive Geraete "
                f"— Stand {eintrag.get('stand')} (hinkt nach!)"
            )
            zeilen.append(
                f"      seit {eintrag.get('zeitraum')}: "
                f"{eintrag.get('installationen_gesamt')} installiert, "
                f"{eintrag.get('deinstallationen_gesamt')} wieder geloescht "
                f"— {eintrag.get('geblieben_prozent')} % geblieben"
            )
        elif name == "play_store_besucher":
            zeilen.append(
                f"  ✓ Store-Eintrag: {eintrag.get('besucher_gesamt')} Besucher "
                f"insgesamt, {eintrag.get('installationen_gesamt')} davon "
                f"installiert"
            )
            if eintrag.get("herkunft_aussagekraeftig"):
                for herkunft, zahl in list(
                    (eintrag.get("besucher_je_herkunft") or {}).items()
                )[:6]:
                    zeilen.append(f"      {herkunft}: {zahl}")
            else:
                zeilen.append(
                    "      Herkunft: von Play nicht aufgeschluesselt "
                    "(alles „Other“ — zu wenig Verkehr fuer die Trennung)"
                )
        elif name == "play_vitals":
            for art, beschriftung in (("abstuerze", "Abstürze"), ("anr", "ANR")):
                werte = eintrag.get(art) or {}
                if not werte.get("ok"):
                    zeilen.append(f"  ✗ {beschriftung}: {werte.get('fehler')}")
                    continue
                verlauf = werte.get("verlauf") or []
                if not verlauf:
                    # Play weist Vitals erst ab einer Mindestzahl von Geraeten
                    # aus. Keine Zeile heisst deshalb nicht „keine Abstuerze",
                    # sondern „zu wenige Geraete fuer eine Aussage".
                    zeilen.append(
                        f"  ~ {beschriftung}: keine Daten — zu wenige Geraete "
                        f"fuer Googles Schwellwert (Stand {werte.get('stand')})"
                    )
                    continue
                letzter = verlauf[-1]
                zeilen.append(
                    f"  ✓ {beschriftung}: zuletzt {letzter.get('tag')} — "
                    f"{letzter.get('crashRate') or letzter.get('anrRate')} "
                    f"(Stand {werte.get('stand')}, frischer als die CSVs)"
                )
        elif name == "play_android_versionen":
            oben = list((eintrag.get("aktive_geraete_je_os") or {}).items())[:5]
            zeilen.append(f"  ✓ Android-Fassungen (Stand {eintrag.get('stand')}):")
            for os_version, zahl in oben:
                zeilen.append(f"      API {os_version}: {zahl} Geraete")
        elif name == "app_check_verkehr":
            urteile = eintrag.get("pruefungen_je_urteil") or {}
            zeilen.append(
                "  ✓ App Check: "
                + (
                    ", ".join(f"{k}={v}" for k, v in urteile.items())
                    if urteile
                    else "keine Pruefungen diesen Monat"
                )
            )
        elif name == "github_ci":
            zeilen.append(f"  ✓ CI: {eintrag.get('anzahl')} letzte Laeufe")
            for lauf in eintrag.get("letzte", [])[:3]:
                zeilen.append(
                    f"      {lauf.get('zeit', '')[:10]} {lauf.get('name')}: "
                    f"{lauf.get('ergebnis')}"
                )
        elif name == "webseite":
            for adresse, werte in (eintrag.get("seiten") or {}).items():
                if "fehler" in werte:
                    zeilen.append(f"  ✗ {adresse}: {werte['fehler']}")
                else:
                    fremde = werte.get("fremde_hosts") or []
                    zeilen.append(
                        f"  ✓ {adresse}: HTTP {werte['status']}, "
                        f"{len(fremde)} fremde Hosts"
                        + (f" — {', '.join(fremde[:4])}" if fremde else "")
                    )
        elif name == "play_rezensionen":
            zeilen.append(f"  ✓ Rezensionen: {eintrag.get('anzahl')}")
            for rez in eintrag.get("rezensionen", [])[:5]:
                zeilen.append(
                    f"      {rez.get('sterne')}★ ({rez.get('fassung')}): "
                    f"{(rez.get('text') or '')[:70]}"
                )
        elif name == "play_installationen":
            zeilen.append(
                f"  ✓ Aktive Geraete: {eintrag.get('aktive_geraete_gesamt')} "
                f"— Stand {eintrag.get('stand')} (hinkt nach!)"
            )
            for code, zahl in eintrag["aktive_geraete_je_versionscode"].items():
                zeilen.append(f"      Versionscode {code}: {zahl}")
        elif name == "firestore":
            for sammlung, werte in eintrag["sammlungen"].items():
                if werte.get("ok"):
                    zeilen.append(
                        f"  ✓ {sammlung}: {werte['anzahl']} Dokumente, "
                        f"juengstes {werte['juengster']}"
                    )
                    for version, zahl in (
                        werte.get("ereignisse_je_version") or {}
                    ).items():
                        zeilen.append(f"      aus Fassung {version}: {zahl}")
                else:
                    zeilen.append(f"  ✗ {sammlung}: {werte['fehler']}")
        elif name == "github":
            zeilen.append(
                f"  ✓ GitHub {eintrag['repo']}: "
                f"{'privat' if eintrag['privat'] else 'oeffentlich'}, "
                f"{eintrag['sterne']} Sterne, "
                f"{eintrag['offene_issues']} offene Issues"
            )

    return "\n".join(zeilen)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--key",
        default=os.environ.get("PLAY_SERVICE_ACCOUNT_JSON")
        or str(Path.home() / ".config" / "play-console" / "aurora-play-sa.json"),
        help="Pfad zur Play-Dienstkonto-JSON. Default: $PLAY_SERVICE_ACCOUNT_JSON",
    )
    parser.add_argument(
        "--texte",
        action="store_true",
        help=(
            "Holt die Freitexte aus dem Feedback mit. Das sind Gesundheitsdaten "
            "— ohne dieses Flag kommen nur Anzahl und Zeitpunkt."
        ),
    )
    parser.add_argument(
        "--out",
        default=str(DEFAULT_OUTPUT),
        help=f"Ziel der JSON-Ausgabe. Default: {DEFAULT_OUTPUT}",
    )
    args = parser.parse_args()

    key_path = Path(args.key).expanduser()

    log("Frage Quellen ab …")
    bericht = {
        "erstellt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "paket": PACKAGE_NAME,
        "hinweis": (
            "Jede Quelle traegt ihr eigenes Stand-Datum. Die "
            "Installationsstatistik von Play hinkt mehrere Tage nach; die "
            "Kanaele und Firestore sind aktuell."
        ),
        "quellen": [
            play_tracks(key_path),
            play_bestand(key_path),
            play_installationen(key_path),
            play_store_besucher(key_path),
            play_vitals(key_path),
            play_android_versionen(key_path),
            play_rezensionen(key_path),
            firestore(mit_texten=args.texte),
            app_check_verkehr(),
            github(),
            github_ci(),
            webseite(),
        ],
    }

    ziel = Path(args.out).expanduser()
    ziel.parent.mkdir(parents=True, exist_ok=True)
    ziel.write_text(
        json.dumps(bericht, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print(zusammenfassung(bericht))
    print()
    print(f"Vollstaendig als JSON: {ziel}")
    if args.texte:
        print("ACHTUNG: Diese Datei enthaelt Freitexte aus dem Feedback.")

    return 0 if any(q["ok"] for q in bericht["quellen"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())
