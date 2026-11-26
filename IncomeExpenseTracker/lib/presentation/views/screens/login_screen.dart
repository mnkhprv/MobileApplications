import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/design_canvas.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// Screen 4 — "Login Screen" (Figma node 4302:2447).
/// View only: login logic lives in [AuthViewModel].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<AuthViewModel>();
    final ok = await vm.login(email: _email.text, password: _password.text);
    if (!mounted) return;

    if (ok) {
      // Clear the back stack so "back" doesn't return to the login form.
      Navigator.of(context)
          .pushNamedAndRemoveUntil(HomeScreen.route, (_) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  void _goRegister() {
    context.read<AuthViewModel>().clearError();
    Navigator.of(context).pushReplacementNamed(RegisterScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: Form(
          key: _formKey,
          child: DesignCanvas(
            builder: (context, s) => [
              ...authHeader(s, title: 'Тавтай морилно уу !', titleTop: 135),
              Positioned(
                left: 75.8 * s,
                top: 245 * s,
                width: 266 * s,
                height: 178 * s,
                child: SvgPicture.asset(
                  'assets/svg/login_illustration.svg',
                  fit: BoxFit.fill,
                ),
              ),
              Positioned(
                left: 46.6 * s,
                width: 328 * s,
                top: 456.8 * s,
                child: Column(
                  children: [
                    AuthTextField(
                      s: s,
                      hint: 'Enter your email address',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 23 * s),
                    AuthTextField(
                      s: s,
                      hint: 'Enter your password',
                      controller: _password,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 36 * s,
                width: 342 * s,
                bottom: (896 - 678 - 69) * s,
                height: 69 * s,
                child: AuthButton(
                  s: s,
                  label: 'Нэвтрэх',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ),
              Positioned(
                left: 72.8 * s,
                bottom: (896 - 796) * s,
                child: GestureDetector(
                  onTap: _goRegister,
                  child: Text('Бүртгүүлэх', style: poppins(size: 18 * s)),
                ),
              ),
              Positioned(
                left: 291.4 * s,
                bottom: (896 - 790) * s,
                child: GestureDetector(
                  onTap: _goRegister,
                  child: Text(
                    'Бүртгүүлэх',
                    style: poppins(
                      size: 12 * s,
                      weight: FontWeight.w700,
                      color: AppColors.link,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
