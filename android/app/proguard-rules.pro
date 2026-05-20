# ─────────────────────────────────────────────────────────────────────────────
# Flutter
# ─────────────────────────────────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ─────────────────────────────────────────────────────────────────────────────
# Voiceon native classes (MethodChannel handlers)
# ─────────────────────────────────────────────────────────────────────────────
-keep class com.personal.voiceon.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# Kotlin
# ─────────────────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Lazy {
    <fields>;
}

# ─────────────────────────────────────────────────────────────────────────────
# Coroutines
# ─────────────────────────────────────────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ─────────────────────────────────────────────────────────────────────────────
# Android / Java standard library
# ─────────────────────────────────────────────────────────────────────────────
-dontwarn sun.misc.**
-keep class sun.misc.Unsafe { *; }
-dontwarn java.lang.invoke.**

# ─────────────────────────────────────────────────────────────────────────────
# DocumentFile / SAF (used by Voiceon's folder picker)
# ─────────────────────────────────────────────────────────────────────────────
-keep class androidx.documentfile.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# MediaMetadataRetriever (used to read audio duration)
# ─────────────────────────────────────────────────────────────────────────────
-keep class android.media.MediaMetadataRetriever { *; }

# ─────────────────────────────────────────────────────────────────────────────
# Drift (SQLite ORM)
# ─────────────────────────────────────────────────────────────────────────────
-keep class drift.** { *; }
-dontwarn drift.**

# ─────────────────────────────────────────────────────────────────────────────
# OkHttp / HTTP (used by http package internally on Android)
# ─────────────────────────────────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# Gson / JSON (if used anywhere transitively)
# ─────────────────────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.gson.**

# ─────────────────────────────────────────────────────────────────────────────
# Google Fonts (font loading at runtime)
# ─────────────────────────────────────────────────────────────────────────────
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ─────────────────────────────────────────────────────────────────────────────
# audio_waveforms
# ─────────────────────────────────────────────────────────────────────────────
-keep class com.simform.audio_waveforms.** { *; }
-dontwarn com.simform.audio_waveforms.**

# ─────────────────────────────────────────────────────────────────────────────
# flutter_sound
# ─────────────────────────────────────────────────────────────────────────────
-keep class com.dooboolab.flutter_sound.** { *; }
-dontwarn com.dooboolab.**
-keep class com.bumptech.glide.** { *; }
-dontwarn com.bumptech.glide.**

# ─────────────────────────────────────────────────────────────────────────────
# permission_handler
# ─────────────────────────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ─────────────────────────────────────────────────────────────────────────────
# url_launcher
# ─────────────────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# ─────────────────────────────────────────────────────────────────────────────
# path_provider
# ─────────────────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# shared_preferences
# ─────────────────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ─────────────────────────────────────────────────────────────────────────────
# intl / date formatting
# ─────────────────────────────────────────────────────────────────────────────
-dontwarn com.ibm.icu.**

# ─────────────────────────────────────────────────────────────────────────────
# Suppress common noise warnings
# ─────────────────────────────────────────────────────────────────────────────
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
