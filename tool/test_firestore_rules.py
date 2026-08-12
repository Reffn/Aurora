"""Prüft firestore.rules gegen die Firebase-Rules-Test-API.

Deployt nichts und legt nichts an: Die Regeln werden serverseitig gegen
simulierte Anfragen ausgewertet. Syntaxfehler meldet dieselbe API mit.

Der Feedback-Rückkanal schreibt ohne Cloud Function direkt aus dem Client
(siehe docs/superpowers/specs/2026-08-04-feedback-rueckkanal-design.md, 5.2).
Die Regeln sind damit die einzige Verteidigung, und die Zusage "niemand kann
fremdes Feedback lesen" muss belegt sein, nicht behauptet.

Voraussetzung: `gcloud auth login` mit Zugriff auf das Firebase-Projekt.

    python tool/test_firestore_rules.py
"""

import json
import pathlib
import subprocess
import sys
import urllib.error
import urllib.request

PROJECT = "auroa-7f66b"
NOW = "2026-08-04T12:00:00Z"
DOC = "/databases/(default)/documents/feedback/doc1"

RULES = (pathlib.Path(__file__).resolve().parent.parent / "firestore.rules").read_text(
    encoding="utf-8"
)

VALID = {
    "category": "Fehler",
    "message": "Die Zeitleiste zeigt nach dem Update keine Eintraege mehr an.",
    "createdAt": NOW,
}


def case(name, expectation, method, data=None, path=DOC):
    request = {"auth": None, "method": method, "path": path, "time": NOW}
    if data is not None:
        request["resource"] = {"data": data}
    return {"_name": name, "expectation": expectation, "request": request}


CASES = [
    # Was funktionieren muss, sonst kommt kein Feedback an.
    case("gültiges Feedback anlegen", "ALLOW", "create", VALID),
    case("mit Kontaktadresse", "ALLOW", "create", {**VALID, "replyEmail": "a@b.de"}),
    case("mit Diagnosedaten", "ALLOW", "create", {**VALID, "diagnostics": "Android 14"}),
    # Kein Lesezugriff — die zentrale Zusage des Rückkanals.
    case("lesen", "DENY", "get"),
    case("auflisten", "DENY", "list", path="/databases/(default)/documents/feedback"),
    case("ändern", "DENY", "update", VALID),
    case("löschen", "DENY", "delete"),
    # Kanal 3: Standortdaten dürfen die Sammlung nie erreichen.
    case("Standortfeld geschmuggelt", "DENY", "create", {**VALID, "location": "50.1,8.6"}),
    # Keine Verkettung mehrerer Meldungen über eine ID.
    case("unbekanntes Feld", "DENY", "create", {**VALID, "profileId": "abc"}),
    # Größen- und Formatgrenzen.
    case("Nachricht zu kurz", "DENY", "create", {**VALID, "message": "kaputt"}),
    case("Nachricht zu lang", "DENY", "create", {**VALID, "message": "x" * 5001}),
    case("category leer", "DENY", "create", {**VALID, "category": ""}),
    case("replyEmail kein String", "DENY", "create", {**VALID, "replyEmail": 42}),
    # Zeitstempel muss vom Server kommen.
    case("createdAt gefälscht", "DENY", "create", {**VALID, "createdAt": "2020-01-01T00:00:00Z"}),
    case("createdAt fehlt", "DENY", "create", {k: v for k, v in VALID.items() if k != "createdAt"}),
    # Alles außerhalb von /feedback ist gesperrt.
    case("fremde Collection", "DENY", "create", VALID,
         path="/databases/(default)/documents/geheim/doc1"),
]


def access_token():
    result = subprocess.run(
        ["gcloud", "auth", "print-access-token"],
        capture_output=True, text=True, shell=True,
    )
    token = result.stdout.strip()
    if not token:
        sys.exit(f"Kein Access-Token. `gcloud auth login` ausführen.\n{result.stderr.strip()}")
    return token


def run_suite(token):
    body = {
        "source": {"files": [{"name": "firestore.rules", "content": RULES}]},
        "testSuite": {
            "testCases": [{k: v for k, v in c.items() if k != "_name"} for c in CASES]
        },
    }
    request = urllib.request.Request(
        f"https://firebaserules.googleapis.com/v1/projects/{PROJECT}:test",
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            # Ohne Quota-Projekt antwortet die API mit 403.
            "x-goog-user-project": PROJECT,
        },
    )
    try:
        with urllib.request.urlopen(request) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        sys.exit(f"HTTP {error.code}\n{error.read().decode('utf-8', 'replace')[:2000]}")


def main():
    result = run_suite(access_token())

    if result.get("issues"):
        print("Syntaxfehler in firestore.rules:")
        for issue in result["issues"]:
            line = issue.get("sourcePosition", {}).get("line", "?")
            print(f"  Zeile {line}: {issue.get('description')}")
        return 1

    results = result.get("testResults", [])
    failed = 0
    for expected, actual in zip(CASES, results):
        passed = actual.get("state") == "SUCCESS"
        failed += 0 if passed else 1
        print(f"{'PASS' if passed else 'FAIL'}  [{expected['expectation']:5}] {expected['_name']}")

    print(f"\n{len(results) - failed}/{len(results)} bestanden")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
