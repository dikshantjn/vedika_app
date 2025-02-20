# Gson Configuration to prevent Proguard from stripping type information
-keepattributes Signature
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**

# Suppress warnings for missing classes related to Razorpay and other annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Keep Razorpay SDK classes and their members from being obfuscated or stripped
-keep class com.razorpay.** { *; }
-keepclassmembers,allowobfuscation class com.razorpay.** { *; }

# Ensure Razorpay SDK classes are not obfuscated or stripped and retain public methods
-keep class com.razorpay.** { public *; }

# For any other missing Razorpay-related classes, if you find more after building, add them here:
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**

-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception