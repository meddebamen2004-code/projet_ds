import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/app_text_field.dart';

/// Returns the created [User] to the login page with Navigator.pop.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  UserRole _role = UserRole.client;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Saisissez votre adresse e-mail.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Adresse e-mail invalide.';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Saisissez un mot de passe.';
    if (v.length < 6) return 'Au moins 6 caractères.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      name: _nameCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      role: _role,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(auth.user);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.error ?? 'Erreur')));
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
              Text('Créer un compte',
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text('Rejoignez la plateforme en quelques secondes.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(
                        value: UserRole.client,
                        label: Text('Client'),
                        icon: Icon(Icons.person_outline)),
                    ButtonSegment(
                        value: UserRole.pro,
                        label: Text('Professionnel'),
                        icon: Icon(Icons.storefront_outlined)),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.lightBg,
                    selectedForegroundColor: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _nameCtrl,
                      hint: 'Nom complet',
                      textInputAction: TextInputAction.next,
                      validator: (v) => _required(v, 'Saisissez votre nom.'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailCtrl,
                      hint: 'Adresse e-mail',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _passCtrl,
                      hint: 'Mot de passe',
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _confirmCtrl,
                      hint: 'Confirmer le mot de passe',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      validator: (v) => v != _passCtrl.text
                          ? 'Les mots de passe ne correspondent pas.'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                  label: 'Créer mon compte',
                  loading: loading,
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}