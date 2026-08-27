# google_mlkit_text_recognition ships one plugin package that reflectively
# references recognizer classes for every script (Chinese, Devanagari,
# Japanese, Korean) even though this app only bundles the Latin-script
# model (see lib/services/ocr_service.dart). R8 can't resolve the unused
# script classes since their optional ML Kit modules aren't included as
# dependencies — safe to ignore, they're never called at runtime.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
