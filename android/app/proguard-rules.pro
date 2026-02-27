# ML Kit optional language recognizers - not used in this app
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Google Play Core (optional deferred components - not used)
-dontwarn com.google.android.play.core.**

# Flutter deferred components (optional - not used)
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Flutter / Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep ML Kit core
-keep class com.google.mlkit.** { *; }
