import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lawyer.dart';
import '../models/account.dart';
import 'home.dart';
import 'Lawyer screens/lawyerHomeScreen.dart';

class New extends StatefulWidget {
  const New({super.key, required this.email, required this.uid});
  final String email;
  final String uid;

  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  bool isLawyer = false;
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  int _experience = 0;
  int _fees = 0;

  final List<String> professions = [
    "Civil",
    "Criminal",
    "Commercial",
    "Labor",
    "Insurance",
    "International",
  ];
  String? _selectedProfession;

  final List<String> provinces = ["Amman", "Zarqaa", "ma'an", "Irbid", "Aqaba"];
  String? _selectedprovinces;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complete Sign-Up',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 68, 40, 18),
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor: Color(0xFFF6F1E9),
      ),
      backgroundColor: Color(0xFFF6F1E9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 25),

              const SizedBox(height: 15),
              _buildUserTypeToggle(),

              const SizedBox(height: 15),
              Divider(),
              const SizedBox(height: 15),
              _buildProfileImagePicker(),
              const SizedBox(height: 20),
              _buildBorderlessTextField("Full Name", _nameController),
              const SizedBox(height: 15),
              _buildBorderlessTextField(
                "Phone Number",
                _phoneController,
                keyboardType: TextInputType.phone,
              ),
              if (isLawyer) ...[
                const SizedBox(height: 15),
                _buildDropdownField("Profession"),
                const SizedBox(height: 15),
                _buildDropdownFieldprov("Province"),
                const SizedBox(height: 15),
                _buildCounter(
                  "Years of Experience",
                  _experience,
                  (val) => setState(() => _experience = val),
                ),
                const SizedBox(height: 15),
                _buildBorderlessTextField("License Number", _licenseController),
                const SizedBox(height: 15),
                _buildBorderlessTextField("Description", _descController),
                const SizedBox(height: 15),
                _buildCounter(
                  "Consultation Fee",
                  _fees,
                  (val) => setState(() => _fees = val),
                ),
              ],
              const SizedBox(height: 25),
              isSubmitting ? CircularProgressIndicator() : _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserTypeCard("I'm a Client", Icons.person, false),
        const SizedBox(width: 16),
        _buildUserTypeCard("I'm a Lawyer", Icons.gavel, true),
      ],
    );
  }

  Widget _buildUserTypeCard(String label, IconData icon, bool value) {
    bool selected = isLawyer == value;
    return GestureDetector(
      onTap: () => setState(() => isLawyer = value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Color.fromARGB(255, 44, 26, 13) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Colors.brown.withOpacity(0.4),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
          ],
          border: Border.all(
            color: selected ? Color(0xFF8B5E3C) : Colors.grey.shade300,
            width: 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 36,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.brown.withOpacity(0.2),
        backgroundImage:
            _selectedImage != null ? FileImage(_selectedImage!) : null,
        child:
            _selectedImage == null
                ? Icon(Icons.camera_alt, color: Colors.brown, size: 30)
                : null,
      ),
    );
  }

  Widget _buildBorderlessTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator:
          (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: Color(0xFFFFFBF5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdownField(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedProfession,
        onChanged: (val) => setState(() => _selectedProfession = val),
        items:
            professions.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  '$e Law',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              );
            }).toList(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: const Color.fromARGB(0, 224, 224, 224),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color.fromARGB(0, 0, 0, 0)),
          ),
        ),
        icon: Icon(
          Icons.arrow_drop_down,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
        dropdownColor: Color(0xFFFFFBF5),
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),
          fontSize: 16,
        ), // <- important
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildDropdownFieldprov(String label) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        value: _selectedprovinces,
        onChanged: (val) => setState(() => _selectedprovinces = val),
        items:
            provinces.map((e) {
              return DropdownMenuItem(
                value: e,
                child: Text(
                  e,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              );
            }).toList(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.brown),
          border: InputBorder.none,
        ),
        icon: Icon(Icons.arrow_drop_down, color: Colors.brown),
        dropdownColor: Color(0xFFFFFBF5),
        style: TextStyle(color: Colors.black87, fontSize: 16),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFBF5),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => onChanged(value > 0 ? value - 1 : 0),
                icon: Icon(Icons.remove),
              ),
              Text(value.toString(), style: TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () => onChanged(value + 1),
                icon: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Color.fromARGB(255, 61, 33, 12),
      ),
      onPressed: _submitForm,
      child: const Text(
        "Submit",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Future<void> pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path); // Convert XFile to File
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isSubmitting = true);

    String imageUrl = '';
    if (_selectedImage != null) {
      try {
        imageUrl = await uploadImageToSupabase(_selectedImage!, widget.uid);
      } catch (e) {
        print("Image upload error: $e");
        setState(() => isSubmitting = false);
        _showError("Failed to upload image");
        return;
      }
    }

    try {
      if (!isLawyer) {
        Account user = Account(
          uid: widget.uid,
          name: _nameController.text,
          email: widget.email,
          number: _phoneController.text,
          isLawyer: false,
          imageUrl: imageUrl,
        );
        await user.addToFirestore();
        Get.to(HomeScreen(account: user));
      } else {
        Lawyer lawyer = Lawyer(
          uid: widget.uid,
          name: _nameController.text,
          email: widget.email,
          number: _phoneController.text,
          licenseNO: _licenseController.text,
          exp: _experience,
          specialization: _selectedProfession,
          province: _selectedprovinces,
          isLawyer: true,
          desc: _descController.text,
          fees: _fees,
          imageUrl: imageUrl,
        );
        await lawyer.addToFirestore();
        Get.to(LawyerHomeScreen(lawyer: lawyer));
      }
    } catch (e) {
      _showError("Something went wrong");
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<String> uploadImageToSupabase(File imageFile, String uid) async {
    final supabase = Supabase.instance.client;
    final bytes = await imageFile.readAsBytes();
    final fileName = '$uid.jpg';
    final path = 'profile_pics/$fileName';

    final response = await supabase.storage
        .from('imagges')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    if (response.isEmpty) throw Exception("Upload failed");

    return supabase.storage.from('imagges').getPublicUrl(path);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
