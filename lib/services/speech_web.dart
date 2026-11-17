import 'dart:async';
import 'dart:js_interop';

import 'speech.dart';

@JS('speechSynthesis')
external JSAny? get _rawSynth;

extension type _Synth._(JSObject _) implements JSObject {
  external void speak(_Utterance u);
  external void cancel();
  external JSArray<_Voice> getVoices();
  external set onvoiceschanged(JSFunction? f);
}

@JS('SpeechSynthesisUtterance')
extension type _Utterance._(JSObject _) implements JSObject {
  external factory _Utterance(String text);
  external set lang(String v);
  external set rate(double v);
  external set pitch(double v);
  external set voice(_Voice? v);
  external set onend(JSFunction? f);
  external set onerror(JSFunction? f);
}

extension type _Voice._(JSObject _) implements JSObject {
  external String get lang;
  external String get name;
}

/// Browser text-to-speech (Web Speech API).
class Speech {
  Speech._();

  static _Synth? get _synth {
    final s = _rawSynth;
    return (s == null || s.isUndefinedOrNull) ? null : s as _Synth;
  }

  static Completer<void>? _running;

  static bool get supported => _synth != null;

  static String _norm(String lang) => lang.replaceAll('_', '-').toLowerCase();

  /// Voices load asynchronously in some browsers; wait briefly for them.
  static Future<List<_Voice>> _voices() async {
    final synth = _synth;
    if (synth == null) return const [];
    var list = synth.getVoices().toDart;
    if (list.isNotEmpty) return list;
    final ready = Completer<void>();
    synth.onvoiceschanged = ((JSAny? _) {
      if (!ready.isCompleted) ready.complete();
    }).toJS;
    await ready.future.timeout(const Duration(milliseconds: 1500), onTimeout: () {});
    synth.onvoiceschanged = null;
    list = synth.getVoices().toDart;
    return list;
  }

  static Future<bool> hasGermanVoice() async =>
      (await _voices()).any((v) => _norm(v.lang).startsWith('de'));

  /// German voices, best match for [lang] first (e.g. de-AT for ÖSD).
  static List<_Voice> _germanOf(List<_Voice> all, String lang) {
    final want = _norm(lang);
    final de = all.where((v) => _norm(v.lang).startsWith('de')).toList();
    de.sort((a, b) {
      final ea = _norm(a.lang) == want ? 0 : 1;
      final eb = _norm(b.lang) == want ? 0 : 1;
      return ea.compareTo(eb);
    });
    return de;
  }

  /// Speaks the whole script and completes when it has finished (or was
  /// stopped). Different speakers get different voices when the browser has
  /// several German voices, otherwise a different pitch.
  ///
  /// The utterances are queued synchronously inside the tap that called
  /// this (voices are normally loaded already), because iOS Safari only
  /// allows speech that starts directly from a user gesture.
  static Future<void> speak(String script, {String lang = 'de-DE', double rate = 0.9}) async {
    final synth = _synth;
    if (synth == null) return;
    // Only cancel when something is playing: Chrome can drop an utterance
    // queued right after cancel().
    if (_running != null) stop();
    final turns = speechTurns(script);
    if (turns.isEmpty) return;
    var all = synth.getVoices().toDart;
    if (all.isEmpty) all = await _voices(); // voices not loaded yet (rare)
    final voices = _germanOf(all, lang);
    final done = Completer<void>();
    _running = done;
    const pitches = [1.0, 0.8, 1.2];
    for (var i = 0; i < turns.length; i++) {
      final t = turns[i];
      final u = _Utterance(t.text)
        ..lang = voices.isEmpty ? lang : voices[t.speaker % voices.length].lang
        ..rate = rate
        ..pitch = voices.length > t.speaker ? 1.0 : pitches[t.speaker % pitches.length];
      if (voices.isNotEmpty) u.voice = voices[t.speaker % voices.length];
      if (i == turns.length - 1) {
        void finish(JSAny? _) {
          if (!done.isCompleted) done.complete();
        }
        u.onend = finish.toJS;
        u.onerror = finish.toJS;
      } else {
        // An error mid-way (e.g. cancelled) also ends the recording.
        u.onerror = ((JSAny? _) {
          if (!done.isCompleted) done.complete();
        }).toJS;
      }
      synth.speak(u);
    }
    // Safety net: never wait forever if the browser drops the end event.
    final words = turns.fold<int>(0, (n, t) => n + t.text.split(' ').length);
    final maxWait = Duration(milliseconds: 4000 + (words * 650 / rate).round());
    await done.future.timeout(maxWait, onTimeout: () {});
    if (identical(_running, done)) _running = null;
  }

  static void stop() {
    _synth?.cancel();
    final r = _running;
    if (r != null && !r.isCompleted) r.complete();
    _running = null;
  }
}
