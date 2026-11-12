import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/design_canvas.dart';
import 'login_screen.dart';

/// Screen 3 — "Register Screen" (Figma node 4302:2417).
/// View only: registration logic lives in [AuthViewModel].
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const route = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final vm = context.read<AuthViewModel>();
    final ok = await vm.register(
      fullName: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (ok) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Амжилттай бүртгүүллээ. Одоо нэвтэрнэ үү.')),
      );
      Navigator.of(context).pushReplacementNamed(LoginScreen.route);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(vm.errorMessage!)));
    }
  }

  void _goLogin() {
    context.read<AuthViewModel>().clearError();
    Navigator.of(context).pushReplacementNamed(LoginScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<AuthViewModel, bool>((vm) => vm.isLoading);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.authBackground,
        body: Form(
          key: _formKey,
          child: DesignCanvas(
            builder: (context, s) => [
              ...authHeader(
                s,
                title: 'Тавтай морилно уу?',
                subtitle: 'Орлого, зарлагаа хянахад тань туслана',
                titleTop: 127,
              ),
              Positioned(
                left: 47.5 * s,
                width: 328.5 * s,
                top: 336.4 * s,
                child: Column(
                  children: [
                    AuthTextField(
                      s: s,
                      hint: 'Бүтэн нэрээ оруулна уу?',
                      controller: _name,
                      validator: Validators.required,
                    ),
                    SizedBox(height: 36 * s),
                    AuthTextField(
                      s: s,
                      hint: 'Имэйлээ оруулна уу?',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 36 * s),
                    AuthTextField(
                      s: s,
                      hint: 'Нууц үгээ оруулаарай',
                      controller: _password,
                      obscure: true,
                      validator: Validators.password,
                    ),
                    SizedBox(height: 36 * s),
                    AuthTextField(
                      s: s,
                      hint: 'Нууц үгээ давтан оруулаарай',
                      controller: _confirm,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.matches(() => _password.text),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 44 * s,
                width: 342 * s,
                bottom: (896 - 722 - 74) * s,
                height: 74 * s,
                child: AuthButton(
                  s: s,
                  label: 'Бүртгүүлэх',
                  isLoading: isLoading,
                  onPressed: _submit,
                ),
              ),
              Positioned(
                left: 44 * s,
                right: 44 * s,
                bottom: (896 - 846) * s,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Хэрэглэгчийн эрхтэй юу?',
                        overflow: TextOverflow.ellipsis,
                        style: poppins(size: 11 * s),
                      ),
                    ),
                    GestureDetector(
                      onTap: _goLogin,
                      child: Text(
                        'Нэвтрэх',
                        style: poppins(size: 14 * s, weight: FontWeight.w700, color: AppColors.link),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
