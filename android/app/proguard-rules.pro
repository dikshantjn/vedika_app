###############################################
# GENERAL PROGUARD CONFIGURATION
###############################################

-keepattributes SourceFile, LineNumberTable, Signature, Exceptions, *Annotation*

-keepclassmembers class * {
    native <methods>;
}

-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

-keep public class * extends java.lang.Exception

###############################################
# FLUTTER SPECIFIC RULES
###############################################

-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.util.** { *; }

###############################################
# RAZORPAY SDK
###############################################

-keep class com.razorpay.** { *; }
-keepclassmembers,allowobfuscation class com.razorpay.** { *; }
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Google Pay via Razorpay
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

###############################################
# FRESCO (Including WebP Support)
###############################################

-keep class com.facebook.** { *; }
-keep class com.facebook.fresco.** { *; }
-keep class com.facebook.common.** { *; }
-keep class com.facebook.cache.** { *; }
-keep class com.facebook.imageformat.** { *; }
-keep class com.facebook.imagepipeline.** { *; }
-keep class com.facebook.imagepipeline.nativecode.WebpTranscoder { *; }
-keep class com.facebook.imagepipeline.nativecode.WebpTranscoderImpl { *; }
-dontwarn com.facebook.**

###############################################
# GOOGLE PLAY CORE & DEFERRED COMPONENTS
###############################################

-keep class com.google.android.play.** { *; }
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.appupdate.** { *; }

-keep interface com.google.android.play.core.** { *; }
-keep class * implements com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.**

-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

###############################################
# FIREBASE
###############################################

-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

###############################################
# KOTLIN SUPPORT
###############################################

-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-dontwarn kotlin.**

###############################################
# GSON (for JSON Parsing)
###############################################

-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }
-dontwarn sun.misc.**

###############################################
# ML KIT TEXT RECOGNITION
###############################################

-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }
-dontwarn com.google.mlkit.vision.text.**
