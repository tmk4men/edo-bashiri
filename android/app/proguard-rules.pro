# WebView + JavaScript bridge safety (no reflection-based JS interface used yet).
# Keep this file even if empty so release builds have a stable rules path.
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
