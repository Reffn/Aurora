# -*- coding: utf-8 -*-
"""Erzeugt das Meldungssymbol aus dem Startsymbol.

Android faerbt Meldungssymbole vollstaendig weiss und liest nur den
Alphakanal. Ein buntes, volldeckendes Startsymbol wird dabei zum Klecks —
genau das stand am 14.08.2026 neben Auroras Erinnerungen: ein leerer Ring.

Gebraucht wird also dieselbe *Form* in Weiss. Die Vorlage
`ic_launcher_foreground.png` traegt sie bereits im Alphakanal; sie hat aber
den breiten Sicherheitsrand eines Adaptive Icons, und der wuerde die Figur in
der schmalen Leiste winzig machen. Deshalb: auf die tatsaechliche Form
zuschneiden, mit dem von Android vorgesehenen Rand neu setzen, Farbe durch
Weiss ersetzen, Alpha behalten.

Die Groessen sind die Android-Vorgabe fuer Meldungssymbole: 24dp, also 24 px
bei mdpi und entsprechend hoch.

Aufruf: python tool/meldungssymbol.py
"""
import os
import sys

from PIL import Image

QUELLE = 'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png'
ZIEL = 'android/app/src/main/res/drawable-{}/ic_notification.png'

# 24dp, die Android-Vorgabe. Der Inhalt darf davon 22dp fuellen; der Rest ist
# Luft, damit das System das Symbol beschneiden kann, ohne die Figur zu
# treffen.
GROESSEN = {
    'mdpi': 24,
    'hdpi': 36,
    'xhdpi': 48,
    'xxhdpi': 72,
    'xxxhdpi': 96,
}
FUELLUNG = 22 / 24


def main():
    if not os.path.exists(QUELLE):
        print('Vorlage fehlt:', QUELLE)
        return 1

    vorlage = Image.open(QUELLE).convert('RGBA')
    alpha = vorlage.split()[-1]

    # Auf die Form zuschneiden. Ohne das bleibt der Sicherheitsrand des
    # Adaptive Icons stehen, und die Figur schrumpft in der Leiste auf die
    # Haelfte.
    kasten = alpha.getbbox()
    if kasten is None:
        print('Vorlage ist ganz durchsichtig')
        return 1
    alpha = alpha.crop(kasten)
    print('zugeschnitten:', vorlage.size, '->', alpha.size)

    # Quadratisch machen, damit das Seitenverhaeltnis beim Skalieren haelt.
    kante = max(alpha.size)
    quadrat = Image.new('L', (kante, kante), 0)
    quadrat.paste(
        alpha,
        ((kante - alpha.width) // 2, (kante - alpha.height) // 2),
    )

    for stufe, px in GROESSEN.items():
        inhalt = max(1, round(px * FUELLUNG))
        klein = quadrat.resize((inhalt, inhalt), Image.LANCZOS)

        flaeche = Image.new('L', (px, px), 0)
        flaeche.paste(klein, ((px - inhalt) // 2, (px - inhalt) // 2))

        # Weiss mit der Form als Alpha. Die Farbe ist egal — Android faerbt
        # ohnehin um —, aber Weiss zeigt dasselbe Bild in jeder Vorschau.
        symbol = Image.merge(
            'RGBA',
            (
                Image.new('L', (px, px), 255),
                Image.new('L', (px, px), 255),
                Image.new('L', (px, px), 255),
                flaeche,
            ),
        )

        ziel = ZIEL.format(stufe)
        os.makedirs(os.path.dirname(ziel), exist_ok=True)
        symbol.save(ziel)

        deckung = sum(flaeche.getdata()) / (px * px * 255)
        print(f'{stufe:8s} {px:3d}px  Deckung {deckung:.0%}  -> {ziel}')

    return 0


if __name__ == '__main__':
    sys.exit(main())
