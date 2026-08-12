# Das Chamäleon im Ankermenü

Stand: 2026-08-05. Setzt auf `docs/oberflaechen-richtlinien.md` auf, besonders
Regel 4 (Sättigung hat eine Aufgabe), Regel 5 (Das Bild trägt) und Regel 6
(Größen sind Untergrenzen).

## Was entschieden ist

Das Logo-Chamäleon wird Auroras Begleiter und ersetzt im Ankermenü die
Material-Icons. **Die Figur bleibt über alle zwölf Bereiche gleich, nur ihr
Requisit wechselt.** Wer sie einmal gelernt hat, erkennt sie überall wieder —
das ist die Anforderung von W3C COGA, neue Bedienlogik nicht zwölfmal zu
verlangen.

Die Figur hält das Requisit vorgestreckt vor der Brust. Vorher hing es in der
herabhängenden Hand, wo es bei Menügröße ein unlesbarer Fleck war.

## Die zwölf Zuordnungen

| Bereich | Requisit | Bereich | Requisit |
|---|---|---|---|
| Halt | Anker | Kontakte | Adresskarte mit Kopf |
| Notfall | Warndreieck | Finder | Lupe |
| Chat | Sprechblase | Hilfe | Medizinisches Kreuz |
| Kalender | Kalenderblatt | Spiele | Würfel |
| Medikamente | Kapsel | Zeitachse | Sanduhr |
| Tagebuch | Buch | Feedback | Briefumschlag |

Notfall trug zuerst einen Telefonhörer, Hilfe einen Rettungsring. Beide wurden
getauscht: Der Hörer las als zwei Pflaster, der Rettungsring als Auge — und er
war bei Menügröße von der Lupe kaum zu unterscheiden. Dreieck und Kreuz sind mit
nichts anderem in der Serie verwechselbar.

## Requisiten tragen keine Farbe

Alle Requisiten sind cremeweiß mit dunkler Kontur. Das ist keine Ästhetik,
sondern die Vier-Bänder-Regel: Farbe gehört zur **Handlung** (`go` / `wait` /
`signal`). Zwölf bunte Requisiten hätten dieses Band besetzt. Der Regenbogen der
Figur darf farbig sein, weil er konstant ist und deshalb nie etwas signalisiert.

## Das weiße Feld — nur wo der Grund farbig ist

Nach Richtlinie 4 tragen Halt, Notfall und Hilfe volle Farbfläche, die neun
anderen Bereiche eine ruhige dunkle Fläche mit Farbstreifen.

- **Farbige Zeile:** weißes Feld hinter der Figur. Ihr Kopf ist rot und
  verschwände sonst auf der roten Notfall-Zeile. Das Feld ist Schutz.
- **Ruhige Zeile:** kein Feld. Die Figur trägt selbst — gemessen gegen
  `#36343B`: Median **6.1:1**, oberes Zehntel **11:1**. Die 18 % der Fläche
  unter 3:1 sind ihre eigene dunkle Außenkontur; Binnendetails wie Augenring und
  Armlinie liegen auf der hellen Figur und bleiben sichtbar.

Ein weißes Feld auf der dunklen Zeile wäre das hellste Element auf dem Schirm
und zöge den Blick auf eine Zeile, die gerade nicht wichtig ist. Am Gerät
geprüft: sechs weiße Blöcke untereinander waren lauter als Farbe und Text
zusammen.

## Größen

- Bildfeld **88 × 72 dp** in der 110 dp hohen Zeile.
- Assets **320 × 256 px** (5:4).

Querformat, weil die Figur mit vorgestrecktem Requisit breiter baut (520) als
sie hoch ist (461). In einem quadratischen Feld schrumpfte der Kopf, um den Arm
unterzubringen — das Auge ist aber die Form, die bei dieser Größe am besten
trägt. Die Zeile hat Breite übrig, nicht Höhe.

## Alle zwölf Bilder teilen einen Ausschnitt

Der Zuschnitt wird **einmal** aus der Vereinigung aller zwölf Bounding-Boxen
bestimmt und dann auf alle angewandt. Trimmt man jedes Bild auf seinen eigenen
Inhalt, zeichnet dasselbe Chamäleon von Zeile zu Zeile unterschiedlich groß —
und die Figur soll die Konstante sein.

Aktueller Ausschnitt bei 640 px Renderauflösung: 599 × 479 um den Mittelpunkt
der gemeinsamen Box, mit 4 % Rand.

## Renderrezept für neue Requisiten

Umriß in der **XZ-Ebene** modellieren, Dicke in Y, ohne Bone-Parenting. Der
`prop`-Knochen dreht mit dem Arm; seine lokalen Achsen stehen dann schräg zum
Bild, und jede Koordinate müßte zurückgerechnet werden. Für Standbilder zählt
nur, was die Kamera sieht.

Der Umriß wird zu einem Körper mit Dicke extrudiert, **bevor** Solidify die
Kontur stülpt. Ohne diese Dicke steht die Hülle nur nach vorn und hinten über
und bleibt aus Kamerasicht unsichtbar.

Drei Solidify-Einstellungen weichen vom Blender-Standard ab. Fehlt eine,
entsteht keine brauchbare Kontur:

| Einstellung | Wert | Ohne sie |
|---|---|---|
| `offset` | **1.0** | Hülle wächst nach innen, keine Kontur |
| `use_rim` | **False** | dunkle Keile an spitzen Ecken |
| Flächennormalen | nach außen | `use_flip_normals` stülpt in die falsche Richtung |

Materialslots: `[farbe, dark]`, `material_offset = 1`. `dark` hat
`use_backface_culling = True` — das ist der Inverted-Hull-Trick.

**Mindestbreite 0.10 für jedes Detail** — das Doppelte der Konturstärke 0.04.
Darunter füllt die Hülle von beiden Seiten zu und das Detail wird ein schwarzer
Fleck. Das hat den ersten Sprechblasen-Zipfel gekostet und zwingt bei Dreiecken
zu abgerundeten Ecken.

## Pose

`arm_r` um **0.7 rad um die lokale X-Achse**. X ist die Achse, die im Bild hebt;
Z verschiebt den Arm fast nur in die Tiefe. Bei 1.2 rad überlappt das Requisit
die Schnauze, bei 0.3 rad hängt es wieder auf Hüfthöhe.

Zwei Sackgassen, damit sie niemand wiederholt:

- `pose.bones[…].matrix_basis` zählt bei einem Kind-Knochen relativ zum
  **Eltern**-Knochen, nicht im Armature-Space. Eine Weltachsen-Rotation über
  `matrix_local` greift dort nicht.
- Das MCP-Werkzeug `set_pose` schreibt seine drei Werte bei
  `rotation_mode = 'QUATERNION'` als Quaternion-Komponenten. Das Ergebnis sieht
  aus wie eine Rotation, ist aber nicht die angeforderte. Immer
  `rotation_mode = 'XYZ'` setzen und `rotation_euler` schreiben.

## Nebenbei behoben

`toe_l_b` und `toe_r_b` trugen einen lokalen `z`-Offset von −0.845 und hingen
einen halben Blender-Meter unter dem Fuß, außerhalb des Bildausschnitts. Sie
wurden nie gerendert, hätten aber jede Pose gebrochen, in der der Fuß sichtbar
wird.

## Offen

- **Das Requisit belegt nur etwa ein Viertel der Bildfläche.** Drei Viertel sind
  die immer gleiche Figur. Das ist die Idee, macht den informationstragenden
  Teil aber klein. Die Requisiten um etwa ein Drittel zu vergrößern ist der
  nächste wirksame Schritt; die Grenze setzt der Kopf, den sie nicht überlappen
  dürfen.
- **Ob Betroffene die Zuordnungen lesen, weiß niemand.** Gehört in einen
  ISO-9186-Test. Ebenso offen, ob „Chamäleon" als Maskieren gelesen wird — das
  wäre für DIS-Betroffene verletzend, und dann bleibt es Logo statt Begleiter.
- **Zwei Chamäleons in einer App.** Der Startbildschirm zeigt das flache,
  liegende Logo aus `logo_rainbow.png`, das Menü die aufrechte Figur. Ob Logo
  und Begleiter verschieden sein dürfen, ist nicht entschieden.
- Die Schwanzspirale ist die auffälligste Einzelform der Figur, ohne Bedeutung
  zu tragen. Sie konkurriert mit dem Requisit um Aufmerksamkeit.

## Dateien

- `F:\aurora-chamaeleon\aurora_chamaeleon.blend` — Figur, Rig, zwölf
  Requisitensätze als `prop_<bereich>_*`, gesteuert über `hide_render`
- `assets/images/cham_<bereich>.png` — zwölf Bilder, 320 × 256
- `lib/models/tab_item.dart` — Feld `image`, Icon bleibt Rückfall
- `lib/modules/anchor/anchor_row.dart` — `imageAsset`, Feldregel, Größen
