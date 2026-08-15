"""Stellt die gemalten Chamaeleon-Bilder frei: Kreis und Hintergrund weg, Alpha rein.

Zwei Versuche vorher, zwei Lehren:

1. Von aussen und von einem festen Ring nach innen fluten frass die Figur auf —
   der Ring lag bei mehreren Bildern mitten auf dem Chamaeleon.
2. Nur von den Bildraendern fluten liess den ganzen Kreis stehen — seine Kante
   ist selbst eine starke Kante und damit eine Mauer.

Deshalb zweistufig. Erst wird die Flaeche ausserhalb des Kreises anhand der
Eckfarbe entfernt; das liefert den Kreis. Dann laeuft die Flut von einem Saum
knapp innerhalb der Kreiskante nach innen und bleibt an der dunklen Kontur der
Figur stehen. Unscharfe Kulisse hat keine harte Kante und wird mitgeflutet —
genau das soll passieren.
"""
import sys
import cv2
import numpy as np
from PIL import Image

ZIEL = (320, 256)


def aussenflaeche(bgr, toleranz=26):
    """Alles, was vom Bildrand aus in Eckfarbe erreichbar ist."""
    h, w = bgr.shape[:2]
    maske = np.zeros((h + 2, w + 2), np.uint8)
    # FIXED_RANGE ist hier keine Feinheit, sondern der ganze Trick: ohne das
    # Kennzeichen vergleicht floodFill jeden Nachbarn mit dem *zuletzt
    # gefuellten* Punkt statt mit dem Startpunkt. Ueber einen weichen Verlauf
    # kriecht die Flut dann Schritt fuer Schritt durchs ganze Bild — gemessen
    # 97 Prozent Aussenflaeche bei einem Bild, das zu 60 Prozent Kreis ist.
    flags = 4 | cv2.FLOODFILL_MASK_ONLY | cv2.FLOODFILL_FIXED_RANGE | (255 << 8)
    lo = up = (toleranz,) * 3
    for x, y in [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]:
        if maske[y + 1, x + 1] == 0:
            cv2.floodFill(bgr.copy(), maske, (x, y), 0, lo, up, flags)
    return maske[1:-1, 1:-1] > 0


def figurmaske(bgr, dunkel=110, mindestanteil=0.012, saum=14):
    aussen = aussenflaeche(bgr)
    kreis = (~aussen).astype(np.uint8)

    # Saum knapp innerhalb der Kreiskante — von dort startet die Flut.
    kern = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (saum * 2 + 1,) * 2)
    innen = cv2.erode(kreis, kern)
    saumring = (kreis > 0) & (innen == 0)

    grau = cv2.cvtColor(bgr, cv2.COLOR_BGR2GRAY)
    strich = (grau < dunkel).astype(np.uint8) * 255
    kanten = cv2.Canny(cv2.GaussianBlur(bgr, (3, 3), 0), 70, 180)
    mauer = cv2.dilate(cv2.bitwise_or(strich, kanten),
                       np.ones((3, 3), np.uint8), iterations=2)

    frei = ((mauer == 0) & (kreis > 0)).astype(np.uint8)
    anzahl, marken = cv2.connectedComponents(frei, 4)

    hintergrundmarken = set(np.unique(marken[saumring])) - {0}
    hintergrund = np.isin(marken, list(hintergrundmarken))

    # Der Saum ist breit, damit die Flut sicher startet — abgeschnitten wird
    # aber nur ein schmaler Streifen. Sonst bekommt jede Figur, die den Kreis
    # beruehrt, unten eine gerade Kante. Der gemalte Kreisrand ueberlebt das,
    # faellt aber gleich darauf als loses Stueck weg.
    schmal = cv2.erode(kreis, cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (9, 9)))
    figur = ((schmal > 0) & ~hintergrund).astype(np.uint8)
    figur = cv2.morphologyEx(
        figur, cv2.MORPH_CLOSE,
        cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7)))

    # Kulisse mit eigener Kante — Bambus, Zimmerpflanze, Tischkante — bleibt
    # sonst als loses Stueck stehen. Behalten wird der groesste
    # zusammenhaengende Teil; Requisiten, die die Figur anfasst, gehoeren
    # ohnehin dazu.
    anzahl, marken, stats, _ = cv2.connectedComponentsWithStats(figur, 8)
    if anzahl <= 1:
        return figur
    groesste = 1 + int(np.argmax(stats[1:, cv2.CC_STAT_AREA]))
    return (marken == groesste).astype(np.uint8)


def freistellen(pfad_ein, pfad_aus, dunkel=110, mindestanteil=0.012,
                vorkreis=None):
    bgr = cv2.imread(pfad_ein)

    # Manche Bilder tragen eine gemalte Fassung um die Szene. Die gehoert weg,
    # bevor irgendetwas anderes passiert — sonst ist sie die groesste Figur.
    if vorkreis:
        h, w = bgr.shape[:2]
        rund = np.zeros((h, w), np.uint8)
        cv2.circle(rund, (w // 2, h // 2), int(min(w, h) * vorkreis / 2), 255, -1)
        bgr = np.where(rund[:, :, None] > 0, bgr, 255).astype(np.uint8)

    figur = figurmaske(bgr, dunkel, mindestanteil)

    alpha = cv2.GaussianBlur(figur * 255, (3, 3), 0)
    rgba = cv2.cvtColor(bgr, cv2.COLOR_BGR2BGRA)
    rgba[:, :, 3] = alpha
    im = Image.fromarray(cv2.cvtColor(rgba, cv2.COLOR_BGRA2RGBA))

    kasten = im.getbbox()
    if kasten:
        im = im.crop(kasten)

    im.thumbnail(ZIEL, Image.LANCZOS)
    blatt = Image.new('RGBA', ZIEL, (0, 0, 0, 0))
    blatt.paste(im, ((ZIEL[0] - im.width) // 2, (ZIEL[1] - im.height) // 2))
    blatt.save(pfad_aus)
    print(f'{pfad_aus}  {round(100 * (np.array(blatt)[:, :, 3] > 0).mean())}% belegt')


if __name__ == '__main__':
    freistellen(sys.argv[1], sys.argv[2],
                int(sys.argv[3]) if len(sys.argv) > 3 else 110,
                float(sys.argv[4]) if len(sys.argv) > 4 else 0.012,
                float(sys.argv[5]) if len(sys.argv) > 5 else None)
