import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Saisissez votre adresse e-mail.';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Adresse e-mail invalide.';
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Saisissez votre mot de passe.';
    if (v.length < 6) return 'Au moins 6 caractères.';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Connexion réussie' : auth.error ?? 'Erreur')),
    );
  }

  void _soon(String what) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('$what : bientôt disponible')));

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // hasScrollBody:false => le lien d'inscription est poussé en bas
            // (équivalent du cadre "Espace" dans Figma).
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('R',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(height: 16),
                    Text('Bon retour',
                        style: textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(
                      'Connectez-vous pour réserver ou gérer vos services.',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
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
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => _soon('Mot de passe oublié'),
                        child: Text('Mot de passe oublié ?',
                            style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                        label: 'Se connecter',
                        loading: loading,
                        onPressed: _submit),
                    const SizedBox(height: 12),
                    AppButton(
                        label: 'Continuer avec Google',
                        outlined: true,
                        onPressed: () => _soon('Connexion Google')),
                    const Spacer(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Pas de compte ?',
                            style: textTheme.bodyMedium
                                ?.copyWith(color: AppColors.muted)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _soon('Inscription'),
                          child: Text('Créer un compte',
                              style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}