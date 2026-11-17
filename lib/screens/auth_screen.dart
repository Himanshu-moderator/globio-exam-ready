import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_widgets.dart';

enum AuthMode { logIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.initialMode = AuthMode.signUp});
  final AuthMode initialMode;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthMode _mode = widget.initialMode;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _error;

  bool get _isSignUp => _mode == AuthMode.signUp;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _switch(AuthMode m) {
    if (m == _mode || _busy) return;
    setState(() {
      _mode = m;
      _error = null;
      _formKey.currentState?.reset();
    });
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    // Let the "Please wait…" state paint before the password hashing runs.
    await Future<void>.delayed(const Duration(milliseconds: 16));
    final auth = AuthService.instance;
    final err = _isSignUp
        ? await auth.signUp(name: _name.text, email: _email.text, password: _password.text)
        : await auth.logIn(email: _email.text, password: _password.text);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final wide = w >= 900;
    return Scaffold(
      backgroundColor: GlobioColors.muted,
      body: wide
          ? Row(children: [
              const Expanded(flex: 5, child: _BrandPanel()),
              Expanded(flex: 6, child: Center(child: _formCard(context))),
            ])
          : Column(children: [
              _MobileHeader(onBack: () => Navigator.of(context).pop()),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Center(child: _formCard(context)),
                ),
              ),
            ]),
    );
  }

  Widget _formCard(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return SingleChildScrollView(
      padding: EdgeInsets.all(wide ? 32 : 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: GlobioColors.border),
            boxShadow: [
              BoxShadow(
                color: GlobioColors.brand.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (wide)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: GlobioColors.mutedForeground,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                if (wide) const SizedBox(height: 8),
                Text(
                  _isSignUp ? 'Create your account' : 'Welcome back',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Sign up to take the readiness check and keep your results.'
                      : 'Log in to continue your readiness check.',
                  style: const TextStyle(fontSize: 14, color: GlobioColors.mutedForeground),
                ),
                const SizedBox(height: 22),
                _ModeToggle(mode: _mode, onChanged: _switch),
                const SizedBox(height: 22),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: _isSignUp
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: TextFormField(
                            controller: _name,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            maxLength: AuthLimits.nameMax,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                              counterText: '',
                              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                            ),
                            validator: AuthLimits.validateName,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  maxLength: AuthLimits.emailMax,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    counterText: '',
                    prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                  ),
                  validator: AuthLimits.validateEmail,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  autofillHints: [_isSignUp ? AutofillHints.newPassword : AutofillHints.password],
                  maxLength: AuthLimits.passwordMax,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    counterText: '',
                    helperText: _isSignUp
                        ? 'At least ${AuthLimits.passwordMin} characters, with a letter and a number'
                        : null,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) {
                    if (_isSignUp) return AuthLimits.validateNewPassword(v);
                    return (v == null || v.isEmpty) ? 'Please enter your password' : null;
                  },
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: GlobioColors.destructive.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
                      border: Border.all(color: GlobioColors.destructive.withValues(alpha: 0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline_rounded,
                          color: GlobioColors.destructive, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: GlobioColors.destructive, fontSize: 13)),
                      ),
                    ]),
                  ),
                ],
                const SizedBox(height: 22),
                PillButton(
                  label: _busy
                      ? 'Please wait…'
                      : (_isSignUp ? 'Create account' : 'Log in'),
                  variant: PillVariant.primary,
                  large: true,
                  expand: true,
                  onPressed: _busy ? null : _submit,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account? ' : 'New here? ',
                      style: const TextStyle(fontSize: 13, color: GlobioColors.mutedForeground),
                    ),
                    GestureDetector(
                      onTap: () => _switch(_isSignUp ? AuthMode.logIn : AuthMode.signUp),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Text(
                          _isSignUp ? 'Log in' : 'Sign up',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: GlobioColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GlobioColors.muted,
                    borderRadius: BorderRadius.circular(GlobioTheme.radius - 4),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.shield_outlined, size: 16, color: GlobioColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your account is saved only in this browser. No email confirmation, '
                          'no Google sign-in, and nothing is sent to a server.',
                          style: TextStyle(
                              fontSize: 12, color: GlobioColors.mutedForeground, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final AuthMode mode;
  final ValueChanged<AuthMode> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: GlobioColors.muted,
          borderRadius: BorderRadius.circular(999),
        ),
        child: LayoutBuilder(builder: (context, c) {
          final half = c.maxWidth / 2;
          return Stack(children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              left: mode == AuthMode.logIn ? 0 : half,
              top: 0,
              bottom: 0,
              width: half,
              child: Container(
                decoration: BoxDecoration(
                  color: GlobioColors.brand,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(children: [
              _seg('Log in', AuthMode.logIn),
              _seg('Sign up', AuthMode.signUp),
            ]),
          ]);
        }),
      );

  Widget _seg(String label, AuthMode m) => Expanded(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(m),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: GlobioTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: mode == m ? Colors.white : GlobioColors.mutedForeground,
                ),
                child: Text(label),
              ),
            ),
          ),
        ),
      );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(gradient: GlobioColors.heroGradient),
        child: Stack(children: [
          const Positioned.fill(child: DotPattern(opacity: 0.08)),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GlobioLogo(height: 30),
                const Spacer(),
                const Text('Am I',
                    style: TextStyle(
                        color: Colors.white, fontSize: 44, fontWeight: FontWeight.w700, height: 1.15)),
                const GoldGradientText('exam-ready?',
                    style: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, height: 1.15)),
                const SizedBox(height: 20),
                Text(
                  'Find out before you book your Goethe or ÖSD A1 exam.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 16),
                ),
                const SizedBox(height: 28),
                for (final t in const [
                  'Score for listening, reading, grammar and vocabulary',
                  'Your 2–3 focus areas before you book',
                  'Results saved to your account on this device',
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded, color: GlobioColors.secondary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(t,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w500)),
                      ),
                    ]),
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ]),
      );
}

class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Container(
        color: GlobioColors.brand,
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        height: 64 + MediaQuery.paddingOf(context).top,
        child: Row(children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            tooltip: 'Back',
          ),
          const GlobioLogo(height: 24),
        ]),
      );
}
