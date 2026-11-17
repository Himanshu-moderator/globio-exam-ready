/// Text-to-speech for listening questions.
///
/// On the web this uses the browser's built-in speech engine
/// (`window.speechSynthesis`), so no audio files are downloaded and no
/// third-party server is contacted by the app. Elsewhere (tests) it is a
/// no-op stub.
library;

export 'speech_stub.dart' if (dart.library.js_interop) 'speech_web.dart';

/// Splits a listening script into spoken turns: one per line, with the
/// "A:" / "B:" / "C:" speaker mark removed, and long lines cut at sentence
/// ends (some browsers stop very long utterances early).
List<SpeechTurn> speechTurns(String script) {
  final out = <SpeechTurn>[];
  final mark = RegExp(r'^([A-C]):\s*');
  for (final raw in script.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final m = mark.firstMatch(line);
    final speaker = m == null ? 0 : m.group(1)!.codeUnitAt(0) - 65;
    final text = m == null ? line : line.substring(m.end);
    for (final s in text.split(RegExp(r'(?<=[.!?])\s+'))) {
      if (s.trim().isNotEmpty) out.add(SpeechTurn(speaker, s.trim()));
    }
  }
  return out;
}

class SpeechTurn {
  const SpeechTurn(this.speaker, this.text);

  /// 0 = A (or narrator), 1 = B, 2 = C.
  final int speaker;
  final String text;
}

/// The script as a readable transcript (speaker marks kept for dialogues).
String transcriptOf(String script) => script.trim();
