package com.disapp.dis_app

import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

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
        val manager =
            getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
        manager?.cancel(WegaufzeichnungBootReceiver.MELDUNGS_ID)
        // Dasselbe für den Update-Hinweis: Wer Aurora geöffnet hat, sieht den
        // Neuerungs-Schirm — die Meldung hat ihren Zweck erfüllt.
        manager?.cancel(UpdateHinweisReceiver.MELDUNGS_ID)
    }
}
