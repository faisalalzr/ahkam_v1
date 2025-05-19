import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerHomeScreen.dart';
import 'package:ahakam_v8/screens/home.dart';
import 'package:ahakam_v8/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/account.dart';
import '../models/lawyer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final RxBool _isLoading = false.obs;

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError("Please enter both email and password.");
      return;
    }

    _isLoading.value = true;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? anyUser = userCredential.user;
      if (anyUser == null) throw Exception("User not found.");

      QuerySnapshot userQuery = await _firestore
          .collection('account')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception("User not found in Firestore.");
      }

      DocumentSnapshot userDoc = userQuery.docs.first;
      bool isLawyer =
          (userDoc.data() as Map<String, dynamic>?)?['isLawyer'] ?? false;

      if (isLawyer) {
        Get.off(
          () => LawyerHomeScreen(
            lawyer: Lawyer(
                email: anyUser.email!,
                name: userDoc['name'],
                imageUrl: userDoc['imageUrl'],
                uid: userDoc['uid'],
                desc: userDoc['desc'],
                number: userDoc['number'],
                province: userDoc['province'],
                fees: userDoc['fees'],
                cases: userDoc['cases'],
                rating: userDoc['rating']),
          ),
        );
      } else {
        Get.off(
          () => HomeScreen(
            account: Account(
              email: anyUser.email!,
              name: userDoc['name'],
              imageUrl: userDoc['imageUrl'],
              uid: userDoc['uid'],
            ),
          ),
        );
      }
    } catch (e) {
      _showError("Login failed: ${e.toString().split('] ').last}");
    } finally {
      _isLoading.value = false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                "Login to your Account",
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
              const SizedBox(height: 30),
              _buildLoginButton(),
              const SizedBox(height: 24),
              const Text(
                "- Or sign in with -",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildSocialRow(),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => Get.to(
                      RegisterScreen(),
                      transition: Transition.rightToLeft,
                    ),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
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
    return TextField(
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
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        backgroundColor: const Color.fromARGB(255, 72, 47, 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
      ),
      child: const Text(
        "Login",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialIconButton(icon: Icons.g_mobiledata),
        SizedBox(width: 16),
        _SocialIconButton(icon: Icons.facebook),
        SizedBox(width: 16),
        _SocialIconButton(icon: Icons.alternate_email),
      ],
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  const _SocialIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: Colors.grey[800]),
      ),
    );
  }
}
