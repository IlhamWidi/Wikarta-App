import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/wikarta_appbar.dart';
import '../widgets/wikarta_navbar.dart';
import '../widgets/glassmorph_card.dart';
import '../theme/app_colors.dart';

// ==== MODEL & PROVIDER ====
class UserProfile {
  String name;
  String email;
  String role;
  String password;
  UserProfile({
    required this.name,
    required this.email,
    required this.role,
    required this.password,
  });
}

class ProfileProvider extends ChangeNotifier {
  UserProfile get user => _user;
  UserProfile _user = UserProfile(
    name: "Admin Wikarta",
    email: "admin@wikarta.co.id",
    role: "Admin",
    password: "password",
  );

  void updateProfile(String name, String email) {
    _user.name = name;
    _user.email = email;
    notifyListeners();
  }

  bool changePassword(String oldPass, String newPass) {
    if (_user.password != oldPass) return false;
    _user.password = newPass;
    notifyListeners();
    return true;
  }
}

// ...existing code for ProfileScreen, _ProfileView, EditProfileDialog, ChangePasswordDialog...

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ProfileProvider>(context);
    final user = prov.user;
    return Scaffold(
      appBar: const WikartaAppBar(title: "Profil"),
      body: Center(
        child: GlassmorphCard(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppColors.coolGray,
                child: Text(
                  user.name[0],
                  style: const TextStyle(fontSize: 34, color: AppColors.white),
                ),
              ),
              const SizedBox(height: 18),
              Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 8),
              Text(user.email, style: const TextStyle(color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Chip(
                label: Text(user.role),
                backgroundColor: AppColors.lightBlue,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => EditProfileDialog(user: user),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit Profil"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ChangePasswordDialog(),
                    ),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text("Ganti Password"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.charcoal,
                  foregroundColor: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: WikartaNavbar(
        selectedIndex: 5,
        onTap: (i) {
          final routes = [
            '/dashboard', '/customers', '/packages', '/invoices', '/tickets', '/profile'
          ];
          Navigator.of(context).pushReplacementNamed(routes[i]);
        },
      ),
    );
  }
}

// ==== EDIT PROFILE DIALOG ====
class EditProfileDialog extends StatefulWidget {
  final UserProfile user;
  const EditProfileDialog({super.key, required this.user});
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.user.name);
    _email = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      Provider.of<ProfileProvider>(context, listen: false).updateProfile(
        _name.text,
        _email.text,
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Profil"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: "Nama"),
                  validator: (v) => v == null || v.isEmpty ? "Nama wajib diisi" : null,
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: "Email"),
                  validator: (v) => v == null || !v.contains("@") ? "Format email salah" : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Simpan"),
        ),
      ],
    );
  }
}

// ==== GANTI PASSWORD DIALOG ====
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});
  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  bool _saving = false;
  String? _error;

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      final prov = Provider.of<ProfileProvider>(context, listen: false);
      if (!prov.changePassword(_old.text, _new1.text)) {
        setState(() {
          _error = "Password lama salah!";
          _saving = false;
        });
        return;
      }
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ganti Password"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _old,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password Lama"),
                  validator: (v) => v == null || v.isEmpty ? "Password wajib diisi" : null,
                ),
                TextFormField(
                  controller: _new1,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password Baru"),
                  validator: (v) => v == null || v.length < 6 ? "Minimal 6 karakter" : null,
                ),
                TextFormField(
                  controller: _new2,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Ulangi Password"),
                  validator: (v) => v != _new1.text ? "Password tidak sama" : null,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Simpan"),
        ),
      ],
    );
  }
}