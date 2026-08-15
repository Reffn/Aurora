# R8-Regeln für den Release-Build.
#
# Ohne diese Datei stürzte Aurora nach jedem App-Update und nach jedem
# Geräteneustart ab — belegt am 8. August 2026 auf dem S24, Version 3.0.17:
#
#   java.lang.RuntimeException: Unable to start receiver
#     com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
#   Caused by: java.lang.IllegalStateException: TypeToken must be created with
#     a type argument ... make sure that generic signatures are preserved.
#
# Der Grund ist bitter: Genau der Empfänger, der die geplanten Erinnerungen
# nach Neustart und Update wiederherstellt, liest sie über Gson zurück. R8
# wirft die generischen Signaturen weg, Gson kann den Typ nicht mehr
# bestimmen, der Empfänger stirbt beim Start — und mit ihm die Erinnerungen.
#
# Sichtbar wird das nur beim *Update* über eine bestehende Installation, nicht
# bei der Erstinstallation. Deshalb überlebte der Fehler jeden bisherigen
# Testdurchlauf: Wir haben immer frisch installiert.

# --- Signaturen erhalten -----------------------------------------------------
# Gson braucht die generischen Typen zur Laufzeit. Das ist die Zeile, an der
# der Absturz hing.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# --- flutter_local_notifications ---------------------------------------------
# Der Empfänger und alles, was er zum Zurücklesen braucht.
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# --- Gson --------------------------------------------------------------------
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-dontwarn sun.misc.**
