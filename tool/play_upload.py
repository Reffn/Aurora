"""Laedt das Release-AAB in die Google Play Console.

Nutzt die Google Play Developer API v3 mit einem Service-Account. Der
Schluessel liegt ausserhalb des Repos; der Pfad kommt aus der Umgebung
(PLAY_SERVICE_ACCOUNT_JSON) oder aus --key. Ohne Schluessel bricht das
Skript ab, statt still nichts zu tun.

Voraussetzungen:
    pip install google-api-python-client google-auth

Beispiel:
    python tool/play_upload.py --track internal
    python tool/play_upload.py --track production --rollout 0.1
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

PACKAGE_NAME = "com.disapp.dis_app"
SCOPES = ["https://www.googleapis.com/auth/androidpublisher"]

REPO_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_AAB = REPO_ROOT / "build" / "app" / "outputs" / "bundle" / "release" / "app-release.aab"


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--key",
        default=os.environ.get("PLAY_SERVICE_ACCOUNT_JSON"),
        help="Pfad zur Service-Account-JSON. Default: $PLAY_SERVICE_ACCOUNT_JSON",
    )
    parser.add_argument("--aab", default=str(DEFAULT_AAB), help="Pfad zum AAB")
    parser.add_argument(
        "--notes",
        default=str(REPO_ROOT / "docs" / "play-release-notes-3.0.15.txt"),
        help="Textdatei mit den Release-Notes (de-DE)",
    )
    parser.add_argument(
        "--track",
        default="internal",
        choices=["internal", "alpha", "beta", "production"],
        help="Zielspur. Default: internal",
    )
    parser.add_argument(
        "--rollout",
        type=float,
        default=None,
        help="Stufenweiser Rollout als Anteil, z.B. 0.1. Ohne Angabe: vollstaendig",
    )
    parser.add_argument(
        "--promote",
        type=int,
        default=None,
        metavar="VERSIONCODE",
        help=(
            "Einen bereits hochgeladenen versionCode in die Spur heben, statt "
            "neu hochzuladen. Play lehnt einen zweiten Upload desselben "
            "versionCode ab, deshalb ist das der Weg von internal nach production."
        ),
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Alles pruefen, Edit anlegen, aber nicht committen",
    )
    return parser.parse_args()


def fail(message: str) -> None:
    print(f"FEHLER: {message}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    args = parse_args()

    if not args.key:
        fail(
            "Kein Service-Account-Schluessel. Setze PLAY_SERVICE_ACCOUNT_JSON "
            "oder uebergib --key. Siehe docs/play-store-veroeffentlichung.md"
        )

    key_path = Path(args.key)
    if not key_path.is_file():
        fail(f"Schluesseldatei nicht gefunden: {key_path}")

    aab_path = Path(args.aab)
    if args.promote is None and not aab_path.is_file():
        fail(f"AAB nicht gefunden: {aab_path}\nErst bauen: flutter build appbundle --release")

    notes_path = Path(args.notes)
    if not notes_path.is_file():
        fail(f"Release-Notes nicht gefunden: {notes_path}")

    notes = notes_path.read_text(encoding="utf-8").strip()
    if len(notes) > 500:
        fail(f"Release-Notes sind {len(notes)} Zeichen lang, Play erlaubt hoechstens 500.")

    credentials = service_account.Credentials.from_service_account_file(
        str(key_path), scopes=SCOPES
    )
    service = build("androidpublisher", "v3", credentials=credentials, cache_discovery=False)
    edits = service.edits()

    edit_id = edits.insert(body={}, packageName=PACKAGE_NAME).execute()["id"]
    print(f"Edit angelegt: {edit_id}")

    if args.promote is not None:
        version_code = args.promote
        print(f"Promote: bestehender versionCode {version_code}, kein Upload")
    else:
        media = MediaFileUpload(
            str(aab_path), mimetype="application/octet-stream", resumable=True
        )
        bundle = edits.bundles().upload(
            editId=edit_id, packageName=PACKAGE_NAME, media_body=media
        ).execute()
        version_code = bundle["versionCode"]
        print(f"AAB hochgeladen, versionCode {version_code}")

    release: dict = {
        "versionCodes": [str(version_code)],
        "releaseNotes": [{"language": "de-DE", "text": notes}],
    }
    if args.rollout is not None:
        release["status"] = "inProgress"
        release["userFraction"] = args.rollout
    else:
        release["status"] = "completed"

    edits.tracks().update(
        editId=edit_id,
        track=args.track,
        packageName=PACKAGE_NAME,
        body={"track": args.track, "releases": [release]},
    ).execute()
    print(f"Spur '{args.track}' gesetzt ({release['status']})")

    if args.dry_run:
        edits.delete(editId=edit_id, packageName=PACKAGE_NAME).execute()
        print("Dry-Run: Edit verworfen, nichts veroeffentlicht.")
        return

    try:
        edits.commit(editId=edit_id, packageName=PACKAGE_NAME).execute()
        print(f"Veroeffentlicht auf '{args.track}', versionCode {version_code}")
        return
    except HttpError as exc:
        # Steht an der App noch etwas offen -- eine Ablehnung, eine
        # unbeantwortete Deklaration --, dann verweigert Play das
        # automatische Einreichen und nennt den Parameter, der fehlt.
        # Der Upload selbst ist davon nicht betroffen.
        if b"changesNotSentForReview" not in exc.content:
            raise

    edits.commit(
        editId=edit_id,
        packageName=PACKAGE_NAME,
        changesNotSentForReview=True,
    ).execute()
    print(
        f"Hochgeladen auf '{args.track}', versionCode {version_code}.\n"
        "ABER: Play hat das automatische Einreichen verweigert -- an der App\n"
        "steht noch etwas offen (Ablehnung, unbeantwortete Deklaration).\n"
        "Das Bundle liegt in der Spur, geprueft wird es erst, wenn du in der\n"
        "Play Console unter 'App-Inhalte' das Offene klaerst und die\n"
        "Aenderungen dort zur Pruefung sendest."
    )


if __name__ == "__main__":
    main()
