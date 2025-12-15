import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLogin = true;
  var _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';
  final _forgotPasswordEmailController = TextEditingController();

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        if (_isLogin) {
          // LOG IN
          await _auth.signInWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );
        } else {
          // SIGN UP
          UserCredential userCred = await _auth.createUserWithEmailAndPassword(
            email: _userEmail,
            password: _userPassword,
          );

          // Update Display Name
          await userCred.user!.updateDisplayName(_userName);

          // Create User Document in Firestore (Critical for Profile/Checkout)
          await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
            'name': _userName,
            'email': _userEmail,
            'phone': '',
            'address': '',
          });
        }
      } on FirebaseAuthException catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Error'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      } catch (err) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email to receive a reset link.'),
            const SizedBox(height: 10),
            TextField(
              controller: _forgotPasswordEmailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final email = _forgotPasswordEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) return;
              Navigator.of(ctx).pop();
              try {
                await _auth.sendPasswordResetEmail(email: email);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset email sent!'), backgroundColor: Colors.green));
              } catch (e) {
                // handle error
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 50, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    if (!_isLogin)
                      TextFormField(
                        key: const ValueKey('username'),
                        validator: (value) => (value == null || value.length < 4) ? 'Enter full name' : null,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        onSaved: (value) => _userName = value!.trim(),
                      ),

                    TextFormField(
                      key: const ValueKey('email'),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Enter valid email' : null,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address'),
                      onSaved: (value) => _userEmail = value!.trim(),
                    ),

                    TextFormField(
                      key: const ValueKey('password'),
                      validator: (value) => (value == null || value.length < 7) ? 'Password too short' : null,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      onSaved: (value) => _userPassword = value!.trim(),
                    ),
                    const SizedBox(height: 12),

                    if (_isLogin && !_isLoading)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPasswordDialog,
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                    if (_isLoading) const CircularProgressIndicator(),
                    if (!_isLoading)
                      ElevatedButton(
                        onPressed: _trySubmit,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        child: Text(_isLogin ? 'Login' : 'Signup'),
                      ),
                    if (!_isLoading)
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? 'Create new account' : 'I already have an account'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}