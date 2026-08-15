package com.disapp.dis_app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.io.File

/**
 * Sagt nach einem Geräteneustart, dass die Wegaufzeichnung pausiert.
 *
 * Warum eine Meldung und kein Start: Der Positionsdienst ist ein
 * Foreground-Service vom Typ `location`. Er darf mit „Bei Nutzung erlauben"
 * weitermessen — aber nur, wenn er gestartet wurde, **während die App sichtbar
 * war**. Ein Start aus BOOT_COMPLETED ist ein Start aus dem Hintergrund; dafür
 * verlangt Android ACCESS_BACKGROUND_LOCATION. Diese Berechtigung wurde
 * bewusst aus dem Manifest entfernt: Sie kostet bei Google Play eine eigene
 * Deklaration samt Demo-Video, und die Nutzerin müsste „Immer erlauben" in den
 * Systemeinstellungen suchen — außerhalb der App, in fremden Menüs.
 *
 * Also der eine Griff statt der Berechtigung. Der Gewinn dabei ist nicht nur
 * juristisch: Bisher erfuhr niemand, dass nach einem Neustart nichts mehr
 * aufgezeichnet wurde. Das Loch im Weg fiel erst auf, wenn jemand nach einer
 * Dissoziation wissen wollte, wo er war — also genau dann, wenn es zu spät ist.
 *
 * Der Wunsch steht in einer Datei, die Dart schreibt (siehe
 * `lib/services/tracking_boot_notice.dart`). Sie trägt auch die beiden Texte:
 * Ein Broadcast-Empfänger startet keine Flutter-Maschine und kennt die
 * gewählte Sprache sonst nicht. Fehlt die Datei, geschieht nichts.
 */
class WegaufzeichnungBootReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AuroraBootReceiver"

        /** Dieselbe Datei wie in `TrackingBootNotice.dateiname`. */
        private const val DATEINAME = "wegaufzeichnung_wunsch.txt"

        /** Eigener Kanal, damit die Nutzerin genau das hier stummschalten kann. */
        private const val KANAL = "aurora_wegaufzeichnung"

        /**
         * Dieselbe Kennung wie in `TrackingBootNotice.meldungsId`. Die App
         * nimmt die Meldung damit beim Start wieder weg.
         */
        const val MELDUNGS_ID = 990_001
    }

    override fun onReceive(context: Context, intent: Intent) {
        val aktion = intent.action
        if (aktion != Intent.ACTION_BOOT_COMPLETED &&
            aktion != Intent.ACTION_MY_PACKAGE_REPLACED &&
            aktion != "android.intent.action.QUICKBOOT_POWERON" &&
            aktion != "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        val datei = File(context.filesDir, DATEINAME)
        if (!datei.exists()) return

        val zeilen = try {
            datei.readLines()
        } catch (e: Exception) {
            Log.w(TAG, "Wunschdatei nicht lesbar", e)
            return
        }

        // Erste Zeile Titel, Rest Text. Ist eine davon leer, wird nichts
        // gezeigt — eine Meldung ohne Worte wäre schlimmer als keine.
        val titel = zeilen.firstOrNull()?.trim().orEmpty()
        val text = zeilen.drop(1).joinToString(" ").trim()
        if (titel.isEmpty() || text.isEmpty()) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as? NotificationManager ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    KANAL,
                    titel,
                    // Niedrig: Sie soll dastehen, nicht klingeln. Wer gerade
                    // hochfährt, braucht keinen Ton.
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }

        val oeffnen = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val absicht = PendingIntent.getActivity(
            context,
            0,
            oeffnen,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

        val bauer = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, KANAL)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        val meldung = bauer
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentTitle(titel)
            .setContentText(text)
            .setStyle(Notification.BigTextStyle().bigText(text))
            .setContentIntent(absicht)
            .setAutoCancel(true)
            .build()

        try {
            manager.notify(MELDUNGS_ID, meldung)
        } catch (e: SecurityException) {
            // Ab Android 13 braucht das POST_NOTIFICATIONS. Ist es nicht
            // erteilt, bleibt es still — kein Absturz beim Hochfahren.
            Log.i(TAG, "Meldung nicht erlaubt", e)
        }
    }
}
