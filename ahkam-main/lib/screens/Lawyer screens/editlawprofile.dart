import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/lawyer.dart';

class EditLawyerProfileScreen extends StatefulWidget {
  final Lawyer lawyer;

  const EditLawyerProfileScreen({super.key, required this.lawyer});

  @override
  State<EditLawyerProfileScreen> createState() =>
      _EditLawyerProfileScreenState();
}

class _EditLawyerProfileScreenState extends State<EditLawyerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _descController;
  late TextEditingController _provinceController;
  late TextEditingController _feesController;

  File? _selectedImage;
  String? _imageUrl;
  bool _isSaving = false;
  int _fees = 0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.lawyer.name);
    _phoneController = TextEditingController(text: widget.lawyer.number);
    _descController = TextEditingController(text: widget.lawyer.desc);
    _provinceController = TextEditingController(text: widget.lawyer.province);
    _feesController = TextEditingController(
      text: widget.lawyer.fees?.toString() ?? '',
    );
    _imageUrl = widget.lawyer.imageUrl;
    _fees = widget.lawyer.fees ?? 0;
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    final file = File(pickedFile.path);
    final fileName = '${widget.lawyer.uid}_${p.basename(pickedFile.path)}';

    final supabase = Supabase.instance.client;

    try {
      await supabase.storage
          .from('imagges')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
      final publicUrl = supabase.storage.from('imagges').getPublicUrl(fileName);

      if (!mounted) return;

      setState(() {
        _selectedImage = file;
        _imageUrl = publicUrl;
      });
    } catch (e) {
      print('Image upload failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to upload image')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _firestore.collection('account').doc(widget.lawyer.uid).update({
        'name': _nameController.text.trim(),
        'desc': _descController.text.trim(),
        'phone': _phoneController.text.trim(),
        'province': _provinceController.text.trim(),
        'fees': _fees,
        'imageUrl': _imageUrl ?? '',
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      print("Error updating profile: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update failed')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator:
            (value) =>
                value == null || value.isEmpty
                    ? 'Please enter your $label'
                    : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Edit Profile", style: GoogleFonts.poppins()),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_imageUrl != null && _imageUrl!.isNotEmpty
                                        ? NetworkImage(_imageUrl!)
                                        : const AssetImage(
                                          'assets/images/brad.webp',
                                        ))
                                    as ImageProvider,
                      ),
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.black,
                        child: Icon(Icons.edit, size: 16, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_nameController, 'Name'),
                _buildTextField(
                  _phoneController,
                  'Phone',
                  keyboardType: TextInputType.phone,
                ),
                _buildTextField(_provinceController, 'Province'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Consultation Fee",
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed:
                                _fees > 0
                                    ? () => setState(() => _fees--)
                                    : null,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "\$$_fees",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => setState(() => _fees++),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descController,
                  maxLines: null,
                  minLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  style: const TextStyle(fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    label: Text(
                      _isSaving ? "Saving..." : "Save changes",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF1E3A5F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
