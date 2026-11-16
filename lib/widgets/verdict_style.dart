import 'package:flutter/material.dart';

import '../services/readiness.dart';
import '../theme/app_theme.dart';

class VerdictStyle {
  const VerdictStyle(this.color, this.soft, this.onSoft, this.icon);
  final Color color;
  final Color soft;
  final Color onSoft;
  final IconData icon;

  static VerdictStyle of(Verdict v) => switch (v) {
        Verdict.ready => const VerdictStyle(
            GlobioColors.success, GlobioColors.successSoft, GlobioColors.success, Icons.verified_rounded),
        Verdict.almost => const VerdictStyle(
            GlobioColors.secondary, GlobioColors.secondarySoft, GlobioColors.foreground, Icons.trending_up_rounded),
        Verdict.notYet => const VerdictStyle(
            GlobioColors.destructive, GlobioColors.destructiveSoft, GlobioColors.destructive, Icons.report_gmailerrorred_rounded),
      };

  static Color statusColor(SkillStatus s) => switch (s) {
        SkillStatus.strong => GlobioColors.success,
        SkillStatus.borderline => const Color(0xFFB7791F),
        SkillStatus.weak => GlobioColors.destructive,
      };

  static Color statusSoft(SkillStatus s) => switch (s) {
        SkillStatus.strong => GlobioColors.successSoft,
        SkillStatus.borderline => GlobioColors.secondarySoft,
        SkillStatus.weak => GlobioColors.destructiveSoft,
      };
}
