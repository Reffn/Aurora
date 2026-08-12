import 'package:dis_app/l10n/app_localizations.dart';
import 'package:dis_app/models/profile.dart';
import 'package:dis_app/utils/time_phase.dart';
import 'package:dis_app/widgets/profile_image_widget.dart';
import 'package:flutter/material.dart';

/// Der Kopf des Ankers: Gruß, Name, Weg zum Anteilswechsel, Begleiter.
///
/// Steht **fest** zwischen Titelzeile und Liste, nicht in der Liste. Das ist
/// die Bedingung dafür, dass der Name hier stehen darf: „Wer bin ich gerade?"
/// muss in einem Griff beantwortet sein, auch wenn jemand bis zum Tagebuch
/// gescrollt hat. Im Scrollbereich wäre die Antwort nach zwei Fingerbreit weg.
///
/// Der Gruß ist der Grund, warum dieser Block überhaupt existiert. Die App
/// begrüßte niemanden — sie zeigte einen Namen und zwölf Knöpfe. Wer nach
/// einem Blackout hochkommt, trifft dann auf ein Werkzeug; jetzt auf jemanden,
/// der da ist.
class AnchorHeader extends StatelessWidget {
  const AnchorHeader({
    required this.profile,
    required this.onSwitchProfile,
    super.key,
  });

  final Profile profile;

  /// Der Weg zurück zur Anteilsauswahl.
  final VoidCallback onSwitchProfile;

  /// Der Begleiter oben rechts.
  ///
  /// Dieselbe Figur, die „Halt" trägt — nicht als zweiter Weg dorthin,
  /// sondern weil sie die einzige ist, die nichts anderes tut als da zu
  /// sitzen. Sie ist deshalb ausdrücklich **kein Bedienelement**: kein
  /// Antippen, keine Semantik, nichts, was ein Screenreader ansagt. Wer sie
  /// für einen Knopf hielte, suchte einen Unterschied zum Halt-Knopf, den es
  /// nicht gibt.
  static const String companion = 'assets/images/cham_halt.png';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = profile.preferredColor;

    // Kein eigener Grund und kein Schatten.
    //
    // Beides stand hier: Der Schatten sollte erklären, warum die Kacheln beim
    // Scrollen mitten im Wort abgeschnitten werden — „Medication" endete auf
    // halber Höhe, als wäre die Fläche kaputt. Er erklärte es auch, aber er
    // legte den Kopf dafür als Kasten auf die Liste. Der Anker löst dasselbe
    // jetzt weicher: Die Liste blendet an ihrer Oberkante aus, und Kopf und
    // Liste stehen auf derselben Tönung. Nichts wird abgeschnitten, also muss
    // auch nichts mehr erklärt werden.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    // Der Punkt steht vor dem Gruß, nicht mehr unten am
                    // Wechsel-Weg. Er beantwortet dieselbe Frage wie der Name
                    // daneben — „wer ist gerade da?" — und beantwortet sie
                    // ohne ein Wort. Deshalb gehört er an den Anfang der
                    // Zeile, die das sagt, und nicht an den Weg, der es
                    // ändert.
                    ExcludeSemantics(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: ClipOval(
                          child: ProfileImageWidget(
                            avatarPath: profile.avatarPath,
                            profileName: profile.name,
                            profileColor: color,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: greetingOf(l10n, DateTime.now().hour),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            // Das Anredekomma steht in allen fünf geführten
                            // Sprachen an derselben Stelle und sieht gleich
                            // aus. Käme eine dazu, die das anders macht,
                            // gehört die ganze Zeile in die ARB-Datei.
                            const TextSpan(text: ', '),
                            TextSpan(
                              text: profile.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        // Gruß und Name stehen in einer Zeile, aber nicht in
                        // einem Gewicht: Der Name ist die Antwort auf „wer bin
                        // ich gerade?", der Gruß nur das Drumherum. Fett
                        // gesetzt bleibt er auch dann das Erste, was auffällt,
                        // wenn beides zusammensteht.
                        style: const TextStyle(fontSize: 25, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Eingerückt auf die Textkante, nicht auf die Punktkante.
                //
                // Der Punkt gehört zur Zeile darüber, und was darunter steht,
                // gehört zum Text — links am Punkt ausgerichtet zog der Weg
                // eine zweite senkrechte Kante durch den Block. So bleibt eine
                // Kante, und die untere linke Ecke wird frei; die Figur rechts
                // steht dadurch weniger gedrängt.
                //
                // Die 6 sind das eigene Polster des Wegs: Abgezogen fluchtet
                // sein Wort mit dem Gruß darüber statt sechs Punkte daneben.
                Padding(
                  padding: const EdgeInsets.only(left: 48 - 6),
                  child: _SwitchProfileLink(
                    label: l10n.anchorSwitchProfile,
                    onTap: onSwitchProfile,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Größer als die 84 von vorher: Gruß und Name stehen jetzt in einer
          // Zeile statt in zweien, der Block links ist damit rund vierzig
          // Punkte flacher geworden. Die Figur nimmt den Platz, der dabei frei
          // wurde — der Kopf bleibt trotzdem niedriger als vorher.
          ExcludeSemantics(
            child: Image.asset(
              AnchorHeader.companion,
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

/// „Das bin ich nicht" unter dem Namen.
///
/// Den Weg gab es vorher nur als „Ausloggen" hinter dem Zahnrad — dasselbe
/// Ziel, aber benannt nach der Technik. Danach hieß er „Anteil wechseln", also
/// nach dem Zweck, und war damit eine Anweisung: Tu etwas.
///
/// Der Satz steht jetzt von innen. Wer hier liest, ist nicht die, die oben
/// steht — und das ist der Zustand, in dem jemand diesen Weg sucht. Der Satz
/// sagt es aus, bevor er zu irgendetwas auffordert; erst danach ist Wechseln
/// überhaupt ein Thema.
///
/// Ohne Rückfrage: Ein Wechsel mitten in der Handlung ist der Normalfall,
/// nicht der Ausrutscher, und ein Bestätigungsdialog stünde genau dort im
/// Weg, wo Reibung am meisten kostet. Verloren geht dabei nichts, was nicht
/// ohnehin schon gespeichert wäre.
class _SwitchProfileLink extends StatelessWidget {
  const _SwitchProfileLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          // Der Text allein wäre eine Trefferfläche von rund 14 Punkten Höhe.
          // Das Polster bringt sie über die 24, die WCAG 2.2 als Untergrenze
          // nennt — mehr gibt die Kopfzeile nicht her, und mehr braucht es
          // hier auch nicht: Der Weg ist eine Abkürzung, kein Notweg.
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.expand_more,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
