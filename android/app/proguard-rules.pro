# Reglas de ProGuard/R8 para el build de release.

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Stripe (solo aplica en la app que lo usa; inocuo en la otra)
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# El SDK de Play Core no se usa con deferred components
-dontwarn com.google.android.play.core.**

# No dejar los nombres de línea fuera: ayuda a leer los crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
