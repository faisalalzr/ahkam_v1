// edit_profile_screen.dart
import 'package:ahakam_v8/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  final Account account;
  const EditProfileScreen({super.key, required this.account});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final List<String> fields = ['name', 'number', 'dob', 'address', 'bio'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var snapshot =
        await FirebaseFirestore.instance
            .collection('account')
            .where('email', isEqualTo: widget.account.email)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      for (String field in fields) {
        _controllers[field] = TextEditingController(text: data[field] ?? '');
      }
    }
  }

  void _saveInfo() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> updatedData = {
        for (var field in fields) field: _controllers[field]!.text,
      };

      var doc =
          await FirebaseFirestore.instance
              .collection('account')
              .where('email', isEqualTo: widget.account.email)
              .limit(1)
              .get();

      if (doc.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('account')
            .doc(doc.docs.first.id)
            .update(updatedData);
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFF5EEDC),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              for (String field in fields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _controllers[field],
                    decoration: InputDecoration(
                      labelText: field[0].toUpperCase() + field.substring(1),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter $field';
                      }
                      return null;
                    },
                  ),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveInfo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
