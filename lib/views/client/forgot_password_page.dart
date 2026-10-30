import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/app_text_field.dart';

/// Two steps on one page:
/// 1. e-mail -> a 6-digit code is generated (shown in a dialog in demo mode)
/// 2. code + new password
class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl =
  TextEditingController(text: widget.initialEmail);
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _codeSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Saisissez votre adresse e-mail.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Adresse e-mail invalide.';
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final code = await auth.requestResetCode(_emailCtrl.text);
    if (!mounted) return;
    if (code == null) {
      _snack(auth.error ?? 'Erreur');
      return;
    }
    setState(() => _codeSent = true);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Code de démonstration'),
        content: Text(
            'Dans une vraie application, ce code serait envoyé par e-mail.\n\nVotre code : $code'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.resetPassword(
      email: _emailCtrl.text,
      code: _codeCtrl.text,
      newPassword: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      _snack('Mot de passe modifié. Connectez-vous.');
      Navigator.of(context).pop();
    } else {
      _snack(auth.error ?? 'Erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.text,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mot de passe oublié',
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(
                _codeSent
                    ? 'Saisissez le code reçu pour ${_emailCtrl.text.trim()} et choisissez un nouveau mot de passe.'
                    : 'Saisissez votre e-mail, nous vous envoyons un code de réinitialisation.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.muted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_codeSent)
                      AppTextField(
                        controller: _emailCtrl,
                        hint: 'Adresse e-mail',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      )
                    else ...[
                      AppTextField(
                        controller: _codeCtrl,
                        hint: 'Code à 6 chiffres',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().length != 6)
                            ? 'Le code contient 6 chiffres.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _passCtrl,
                        hint: 'Nouveau mot de passe',
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Au moins 6 caractères.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmCtrl,
                        hint: 'Confirmer le mot de passe',
                        isPassword: true,
                        validator: (v) => v != _passCtrl.text
                            ? 'Les mots de passe ne correspondent pas.'
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: _codeSent ? 'Réinitialiser' : 'Envoyer le code',
                loading: loading,
                onPressed: _codeSent ? _reset : _sendCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}