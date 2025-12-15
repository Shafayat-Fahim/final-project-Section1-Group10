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

  void _trySubmit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        if (_isLogin) {
          await _auth.signInWithEmailAndPassword(email: _userEmail, password: _userPassword);
        } else {
          UserCredential userCred = await _auth.createUserWithEmailAndPassword(
              email: _userEmail, password: _userPassword);
          await userCred.user!.updateDisplayName(_userName);
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1F24), // Dark Background
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.anchor, size: 100, color: Color(0xFF007BFF)), // Anchor Icon
              const SizedBox(height: 10),
              const Text(
                "ANCHOR SPORTS",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900, // Extra Bold
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Card(
                color: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Full Name", Icons.person),
                            validator: (v) => (v == null || v.length < 4) ? 'Enter name' : null,
                            onSaved: (v) => _userName = v!.trim(),
                          ),
                        const SizedBox(height: 15),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Email", Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null,
                          onSaved: (v) => _userEmail = v!.trim(),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Password", Icons.lock),
                          obscureText: true,
                          validator: (v) => (v == null || v.length < 7) ? 'Short password' : null,
                          onSaved: (v) => _userPassword = v!.trim(),
                        ),
                        const SizedBox(height: 30),
                        if (_isLoading)
                          const CircularProgressIndicator(color: Color(0xFF007BFF))
                        else
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: _trySubmit,
                                  child: Text(_isLogin ? 'LOG IN' : 'SIGN UP'),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin ? 'NEW HERE? CREATE ACCOUNT' : 'HAVE AN ACCOUNT? LOG IN',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ],
                          ),
                      ],
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: const Color(0xFF007BFF)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF007BFF)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}