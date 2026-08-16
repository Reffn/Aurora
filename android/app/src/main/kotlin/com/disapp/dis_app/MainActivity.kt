package com.disapp.dis_app

import android.app.NotificationManager
import android.content.Context
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    /**
     * Hält den Inhalt aus fremden Aufnahmen heraus.
     *
     * `FLAG_SECURE` deckt drei Wege ab, und der wichtigste ist der, an den
     * niemand denkt:
     *
     * 1. **Das Vorschaubild im App-Wechsler.** Android hält den letzten
     *    Bildschirm fest, wenn Aurora in den Hintergrund geht, und legt ihn
     *    auf die Platte. Wer die Übersichtstaste drückt, sieht die
     *    Anteilsliste mit Namen oder einen offenen Chat — ohne die App zu
     *    öffnen und ohne ein Passwort. Das ist kein Angriff, das ist der
     *    Alltag auf einem Gerät, das jemand kurz in die Hand nimmt.
     * 2. Bildschirmfotos und Bildschirmaufnahmen.
     * 3. Übertragung auf einen zweiten Schirm.
     *
     * **Preis, ehrlich benannt:** Wer eine Tagebuchseite abfotografieren
     * wollte, um sie in der Therapie zu zeigen, kann das jetzt nicht mehr
     * innerhalb der App. Android sagt beim Versuch, dass die App es nicht
     * erlaubt — es scheitert also sichtbar, nicht still. Ein Schalter in den
     * Einstellungen wäre die vollständige Antwort; bis es ihn gibt, ist der
     * Schutz die Vorgabe, weil Punkt 1 jeden Tag passiert und das
     * Abfotografieren selten.
     *
     * `onCreate` reicht: Das Flag hängt am Fenster, nicht am Lebenszyklus,
     * und überlebt damit auch das Fortsetzen aus dem Hintergrund unter
     * `singleTop`.
     *
     * Bewacht von test/core/keine_stille_verbindung_test.dart.
     */
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        window.setFlags(
            WindowManager.LayoutParams.FLAG_SECURE,
            WindowManager.LayoutParams.FLAG_SECURE,
        )
    }

    /**
     * Nimmt die Neustart-Meldung weg, sobald Aurora vorn ist.
     *
     * [WegaufzeichnungBootReceiver] stellt sie nach einem Geräteneustart hin.
     * Sie trägt zwar `setAutoCancel`, aber das greift nur beim Antippen — wer
     * Aurora stattdessen vom Startbildschirm öffnet, hätte sie sonst weiter in
     * der Leiste stehen, während längst wieder aufgezeichnet wird. Eine
     * Meldung, die etwas Falsches behauptet, ist schlimmer als keine.
     *
     * `onResume`, nicht `onCreate`: Die Aktivität läuft mit `singleTop`. Liegt
     * Aurora nur im Hintergrund, wird sie fortgesetzt statt neu erzeugt, und
     * `onCreate` bleibt aus — am Gerät nachgemessen, die Meldung blieb stehen.
     * `onResume` deckt beide Wege ab.
     */
    override fun onResume() {
        super.onResume()
        (getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager)
            ?.cancel(WegaufzeichnungBootReceiver.MELDUNGS_ID)
    }
}
