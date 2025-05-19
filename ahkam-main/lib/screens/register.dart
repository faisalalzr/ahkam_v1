import 'package:ahakam_v8/screens/login.dart';
import 'package:ahakam_v8/screens/new.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      var uid = userCredential.user!.uid;

      Get.to(New(email: _emailController.text.trim(), uid: uid));
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed!';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Password must be at least 6 characters.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email address.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "AHKAM",
                  style: const TextStyle(
                    fontSize: 36,
                    fontFamily: 'Times New Roman',
                    color: Color.fromARGB(255, 72, 47, 0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  "Create a New Account",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(235, 31, 31, 31),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(_emailController, "Email", false),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, "Password", true),
                const SizedBox(height: 20),
                _buildTextField(
                  _confirmPasswordController,
                  "Confirm Password",
                  true,
                ),
                const SizedBox(height: 30),
                _buildRegisterButton(),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed:
                          () => Get.off(
                            LoginScreen(),
                            transition: Transition.leftToRight,
                          ),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    bool isObscure,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$hint cannot be empty.";
        }
        if (hint == "Email" &&
            !RegExp(
              r"^[a-zA-Z0-9.+_-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+$",
            ).hasMatch(value)) {
          return "Enter a valid email.";
        }
        if ((hint == "Password" || hint == "Confirm Password") &&
            value.length < 6) {
          return "Password must be at least 6 characters.";
        }
        if (hint == "Confirm Password" && value != _passwordController.text) {
          return "Passwords do not match.";
        }
        return null;
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        backgroundColor: const Color.fromARGB(255, 72, 47, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      child: const Text(
        "Register",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
