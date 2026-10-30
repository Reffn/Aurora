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
 * Sagt nach einem Update einmal, dass Aurora neu ist.
 *
 * Play installiert still. Der Neuerungs-Schirm erscheint erst, wenn jemand
 * die App ohnehin öffnet — wer Aurora nur in schlechten Momenten aufmacht,
 * erführe es dann mitten in der Not. Die Meldung sagt es vorher, ohne Ton.
 * Ein Tippen öffnet Aurora, und dort steht der Neuerungs-Schirm.
 *
 * Nichts verlässt das Gerät: Android ruft `MY_PACKAGE_REPLACED` an die
 * **neue** Fassung, und die stellt die Meldung hin.
 *
 * Die Worte stehen in einer Datei, die Dart bei jedem Start schreibt (siehe
 * `lib/services/update_notice.dart`) — ein Broadcast-Empfänger kennt die in
 * Aurora gewählte Sprache sonst nicht.
 *
 * **Der Fall, an dem es sonst gescheitert wäre.** Die Datei schreibt die
 * *alte* Fassung. Die Fassung, die diesen Empfänger einführt, findet beim
 * ersten Update keine vor — genau das Update, für das er gebaut ist, bliebe
 * stumm. Dann gelten die Texte aus `res/values-…/strings.xml` in der
 * Systemsprache, sofern Aurora schon einmal geöffnet war (die Hive-Datei
 * der Einstellungen liegt vor). Wer die App nie geöffnet hat, bekommt nichts.
 *
 * **Grenze, am Emulator gemessen (06.10.2026):** Wurde Aurora zuletzt über
 * „Beenden erzwingen" gestoppt, steht das Paket auf `stopped=true`, und
 * Android stellt ihm keinen Broadcast zu — auch diesen nicht. Die Meldung
 * bleibt dann aus; der Neuerungs-Schirm erscheint trotzdem beim nächsten
 * Öffnen. Dasselbe gilt für [WegaufzeichnungBootReceiver].
 */
class UpdateHinweisReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "AuroraUpdateHinweis"

        /** Dieselbe Datei wie in `UpdateNotice.dateiname`. */
        private const val DATEINAME = "update_hinweis.txt"

        /**
         * Eigener Kanal: Wer die Meldung nicht will, schaltet genau ihn in
         * den Android-Einstellungen stumm.
         */
        private const val KANAL = "aurora_update"

        /**
         * Dieselbe Kennung wie in `UpdateNotice.meldungsId`. [MainActivity]
         * nimmt die Meldung damit beim Öffnen wieder weg.
         */
        const val MELDUNGS_ID = 990_002

        /**
         * Wo `Hive.initFlutter()` die Einstellungen ablegt:
         * `getApplicationDocumentsDirectory()` ist auf Android `app_flutter`.
         */
        private const val HIVE_ORDNER = "flutter"
        private const val HIVE_EINSTELLUNGEN = "settings.hive"
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_MY_PACKAGE_REPLACED) return

        val (titel, text) = worte(context) ?: return
        if (titel.isEmpty() || text.isEmpty()) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as? NotificationManager ?: return

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(
                    KANAL,
                    context.getString(R.string.update_hinweis_kanal),
                    // Niedrig: Sie soll dastehen, nicht klingeln.
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }

        val oeffnen = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val absicht = PendingIntent.getActivity(
            context,
            MELDUNGS_ID,
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
            .setSmallIcon(R.drawable.ic_notification)
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
            // erteilt, bleibt es still.
            Log.i(TAG, "Meldung nicht erlaubt", e)
        }
    }

    /** Titel und Text: aus der Datei, sonst aus den Ressourcen, sonst nichts. */
    private fun worte(context: Context): Pair<String, String>? {
        val datei = File(context.filesDir, DATEINAME)
        if (datei.exists()) {
            val zeilen = try {
                datei.readLines()
            } catch (e: Exception) {
                Log.w(TAG, "Hinweisdatei nicht lesbar", e)
                emptyList()
            }
            val titel = zeilen.firstOrNull()?.trim().orEmpty()
            val text = zeilen.drop(1).joinToString(" ").trim()
            if (titel.isNotEmpty() && text.isNotEmpty()) return titel to text
        }

        val warSchonOffen = File(
            context.getDir(HIVE_ORDNER, Context.MODE_PRIVATE),
            HIVE_EINSTELLUNGEN,
        ).exists()
        if (!warSchonOffen) return null

        return context.getString(R.string.update_hinweis_titel) to
            context.getString(R.string.update_hinweis_text)
    }
}
