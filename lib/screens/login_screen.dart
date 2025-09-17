import 'package:flutter/material.dart';
import '../widgets/glassmorph_card.dart';
import '../widgets/glassmorph_button.dart';
import '../theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    if (!_formKey.currentState!.validate()) {
      setState(() => _loading = false);
      return;
    }
    await Future.delayed(Duration(seconds: 1));
    if (_emailC.text == "admin@wikarta.co.id" && _passC.text == "password") {
      setState(() => _loading = false);
      if (mounted) Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() {
        _loading = false;
        _error = "Email atau password salah";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.veryLightBlue, AppColors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: GlassmorphCard(
            width: 370,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Wikarta Login",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailC,
                    decoration: const InputDecoration(
                      hintText: "Email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? "Email wajib diisi" : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passC,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    obscureText: _obscure,
                    validator: (v) => v == null || v.isEmpty ? "Password wajib diisi" : null,
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _error!,
                        style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  const SizedBox(height: 22),
                  GlassmorphButton(
                    text: "Login",
                    loading: _loading,
                    onTap: _login,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "© 2025 PT. Wijaya Karya Arta",
                    style: TextStyle(
                      color: AppColors.coolGray,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}