# Flutter Wrapper rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Isar specific rules (to prevent stripping database models)
-keep class **.isar.** { *; }
-keep @dev.isar.IsarProject class * { *; }
-keep @dev.isar.IsarCollection class * { *; }
-keep class * extends dev.isar.IsarCollection { *; }

# Google Play Core rules (fixes R8 "Missing classes" errors)
-dontwarn com.google.android.play.core.**
