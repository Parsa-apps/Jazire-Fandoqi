# Professional ProGuard rules for app size reduction
# Preserves beautiful story audio, billing, and game functionality

-keep class com.parsaapps.amoozesh_fandoghi.MainActivity { *; }
-keep class com.parsaapps.amoozesh_fandoghi.SecureStore { *; }
-keep class com.parsaapps.amoozesh_fandoghi.SecurityModule { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BuildConfig { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BazaarBilling { *; }
-keep class com.parsaapps.amoozesh_fandoghi.MyketBilling { *; }
-keep class com.parsaapps.amoozesh_fandoghi.BillingOutcome { *; }
-keep class com.parsaapps.amoozesh_fandoghi.StoreVendor { *; }
# Store billing SDKs: both use AIDL/reflection over their own model classes,
# so they must survive shrinking. Myket also parses receipts through org.json.
-keep class ir.cafebazaar.poolakey.** { *; }
-keep class ir.myket.billingclient.** { *; }
-keep interface ir.myket.billingclient.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn ir.cafebazaar.poolakey.**
-dontwarn ir.myket.billingclient.**
# The ads-identifier transitive dependency is deliberately excluded from the
# build (kids app, no advertising ID); silence references to it.
-dontwarn com.google.android.gms.ads.identifier.**
-keepclassmembers class * { @android.webkit.JavascriptInterface <methods>; }

-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
