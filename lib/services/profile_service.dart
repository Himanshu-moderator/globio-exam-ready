import 'dart:math';

import 'local_store.dart';

/// Learner profile. The student ID is created once and never changes.
class Profile {
  Profile({
    required this.studentId,
    required this.createdAt,
    this.phone = '',
    this.city = '',
    this.goal = '',
    this.level = '',
    this.targetExam = '',
    this.examDate,
  });

  /// e.g. "GLB-7K3M9Q"
  final String studentId;
  final DateTime createdAt;
  String phone;
  String city;

  /// One of [Profile.goals] or empty.
  String goal;

  /// One of [Profile.levels] or empty.
  String level;

  /// Exam id (see exams.dart) or empty.
  String targetExam;
  DateTime? examDate;

  static const goals = ['Study in Germany', 'Ausbildung', 'Chancenkarte', 'Job / Nursing', 'Family reunion', 'Personal interest'];
  static const levels = ['Beginner (A0)', 'A1', 'A2', 'B1', 'B2 or higher'];

  Map<String, dynamic> toJson() => {
        'id': studentId,
        'created': createdAt.toUtc().toIso8601String(),
        'phone': phone,
        'city': city,
        'goal': goal,
        'level': level,
        'target': targetExam,
        'examDate': examDate?.toUtc().toIso8601String(),
      };

  static Profile? fromJson(Map<String, dynamic> j) {
    final id = j['id'];
    final created = DateTime.tryParse('${j['created']}');
    if (id is! String || !ProfileService.idPattern.hasMatch(id) || created == null) return null;
    String s(String k, int max) {
      final v = j[k];
      return v is String ? (v.length > max ? v.substring(0, max) : v) : '';
    }

    final goal = s('goal', 40);
    final level = s('level', 20);
    return Profile(
      studentId: id,
      createdAt: created.toLocal(),
      phone: s('phone', ProfileService.phoneMax),
      city: s('city', ProfileService.cityMax),
      goal: goals.contains(goal) ? goal : '',
      level: levels.contains(level) ? level : '',
      targetExam: s('target', 20),
      examDate: j['examDate'] == null ? null : DateTime.tryParse('${j['examDate']}')?.toLocal(),
    );
  }
}

class ProfileService {
  ProfileService._();

  static const phoneMax = 20;
  static const cityMax = 60;

  /// "GLB-" + 6 characters without look-alikes (no 0/O, 1/I/L).
  static final idPattern = RegExp(r'^GLB-[A-HJKMNP-Z2-9]{6}$');
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static String _key(String email) => 'globio.profile.v1|$email';
  static const _idsKey = 'globio.studentIds.v1';

  /// Returns the profile, creating it (with a new unique ID) if missing.
  static Future<Profile> ensure(String email, {Random? random}) async {
    final existing = Profile.fromJson(await LocalStore.readMap(_key(email)));
    if (existing != null) return existing;
    final rnd = random ?? Random.secure();
    final taken = (await LocalStore.read(_idsKey) as List?)?.whereType<String>().toSet() ?? <String>{};
    String id;
    do {
      id = 'GLB-${List.generate(6, (_) => _alphabet[rnd.nextInt(_alphabet.length)]).join()}';
    } while (taken.contains(id));
    final p = Profile(studentId: id, createdAt: DateTime.now());
    await LocalStore.write(_key(email), p.toJson());
    await LocalStore.write(_idsKey, [...taken, id]);
    return p;
  }

  static String? validatePhone(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    if (s.length > phoneMax || !RegExp(r'^\+?[0-9 \-]{7,}$').hasMatch(s)) return 'Enter a valid phone number';
    return null;
  }

  static String? validateCity(String? v) =>
      (v ?? '').trim().length > cityMax ? 'At most $cityMax characters' : null;

  /// Saves editable fields. The student ID and join date are kept as they are.
  static Future<bool> save(String email, Profile p) async {
    final current = await ensure(email);
    final merged = Profile(
      studentId: current.studentId,
      createdAt: current.createdAt,
      phone: p.phone.trim(),
      city: p.city.trim(),
      goal: Profile.goals.contains(p.goal) ? p.goal : '',
      level: Profile.levels.contains(p.level) ? p.level : '',
      targetExam: p.targetExam,
      examDate: p.examDate,
    );
    final ok = await LocalStore.write(_key(email), merged.toJson());
    if (ok) AppEvents.instance.changed();
    return ok;
  }
}
