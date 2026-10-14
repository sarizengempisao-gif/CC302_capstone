import 'package:flutter/material.dart';

import '../services/store.dart';
import '../utils/formatters.dart';

/// Sign-in / passenger-registration screen.
///
/// The layout is a two-panel card (blue gradient + form) that collapses to a
/// single column on narrow phones. Credentials for the two demo accounts are
/// shown on the sign-in form so the demo can be run without remembering them.
class Login extends StatefulWidget {
  final VoidCallback onLoggedIn;

  const Login({super.key, required this.onLoggedIn});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _hide = true;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final store = Store.instance;
    if (_register) {
      final error = await store.register(_name.text, _email.text, _pass.text);
      if (error != null && mounted) {
        showMessage(context, error);
      }
      if (error != null) return;
    } else if (store.login(_email.text, _pass.text) == null) {
      showMessage(context, 'Incorrect email or password.');
      return;
    }
    if (mounted) widget.onLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TaxiGo — Sign in')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: _buildLoginCard(),
        ),
      ),
    );
  }

  Widget _buildLoginCard() => LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth > 650;
          final direction = wide ? Axis.horizontal : Axis.vertical;
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Flex(
              direction: direction,
              children: [
                Expanded(
                  flex: wide ? 1 : 0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1455C0), Color(0xFF2789F4)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_taxi, size: 48, color: Colors.white),
                        SizedBox(height: 14),
                        Text('TaxiGo', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                        SizedBox(height: 8),
                        Text('Your ride, made simple.', style: TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 12),
                        Text('Book rides, manage trips, and keep every journey organized.', style: TextStyle(color: Colors.white, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: wide ? 20 : 0, height: wide ? 0 : 18),
                Expanded(
                  flex: wide ? 1 : 0,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_register ? 'Create passenger account' : 'Welcome back', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            if (_register) ...[
                              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => v == null || v.trim().length < 2 ? 'Enter your name.' : null),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)), validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email.' : null),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _pass,
                              obscureText: _hide,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  tooltip: _hide ? 'Show password' : 'Hide password',
                                  onPressed: () => setState(() => _hide = !_hide),
                                  icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                                ),
                              ),
                              validator: (v) => v == null || v.length < 6 ? 'Use at least 6 characters.' : null,
                            ),
                            const SizedBox(height: 18),
                            FilledButton.icon(onPressed: _submit, icon: Icon(_register ? Icons.person_add : Icons.login), label: Text(_register ? 'Create account' : 'Sign in')),
                            TextButton(onPressed: () => setState(() => _register = !_register), child: Text(_register ? 'Already registered? Sign in' : 'New passenger? Register')),
                            if (!_register)
                              const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  'Admin: admin@taxigo.local / Admin123!\nPassenger: passenger@taxigo.local / Passenger123!',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
