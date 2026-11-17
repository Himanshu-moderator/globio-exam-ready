/// Non-web fallback: speech is not available.
class Speech {
  Speech._();

  static bool get supported => false;
  static Future<bool> hasGermanVoice() async => false;
  static Future<void> speak(String script, {String lang = 'de-DE', double rate = 0.9}) async {}
  static void stop() {}
}
