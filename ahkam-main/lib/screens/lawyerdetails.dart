import 'package:ahakam_v8/models/account.dart';
import 'package:ahakam_v8/models/lawyer.dart';
import 'package:ahakam_v8/widgets/reviewWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart'; // NEW

class LawyerDetailsScreen extends StatefulWidget {
  final Account account;
  final String lawyerId;
  const LawyerDetailsScreen({
    super.key,
    required this.account,
    required this.lawyerId,
  });

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen> {
  final _titleCont = TextEditingController();
  final _descriptionCont = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FirebaseFirestore fyre = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>?> getinfo() async {
    try {
      var query = await fyre
          .collection('account')
          .where('uid', isEqualTo: widget.lawyerId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return query.docs.first;
      }
    } catch (e) {
      print('Error fetching lawyer info: $e');
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.light(
              primary: Color(0xFFD4AF37), // gold for selected day and header
              onPrimary: Colors.white, // text on gold background
              surface: Colors.white, // background of the picker
              onSurface: Colors.black, // default text color
              secondary: Color(0xFFF5F5DC), // beige for accents if needed
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFD4AF37), // gold for OK/Cancel
              ),
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.year}-${picked.month}-${picked.day}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFD4AF37), // gold
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black,
              hourMinuteColor: Color(0xFFF5F5DC), // beige background
              dayPeriodColor: Color(0xFFF5F5DC), // AM/PM toggle bg
              dayPeriodTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Colors.white
                    : Colors.black,
              ),
              entryModeIconColor: Color(0xFFD4AF37), // gold
              dialHandColor: Color(0xFFD4AF37),
              dialBackgroundColor: Color(0xFFF5F5DC),
              dialTextColor: MaterialStateColor.resolveWith(
                (states) => states.contains(MaterialState.selected)
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFFD4AF37)),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _sendRequest() async {
    if (_selectedDate == null || _selectedTime == null) return;

    if (_titleCont.text.trim().isEmpty || _descriptionCont.text.trim().isEmpty)
      return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await fyre.collection('account').doc(currentUser.uid).get();
    final username = userDoc.data()?['name'] ?? 'Unknown';

    final lawyerDoc =
        await fyre.collection('account').doc(widget.lawyerId).get();
    final lawyerData = lawyerDoc.data();
    final lawyerName = lawyerData?['name'] ?? 'Unknown';
    final lawyerFees = lawyerData?['fees'] ?? 0;

    final requestRef = fyre
        .collection('requests')
        .doc(); // Use specific doc ref for reliable field writes

    final request = {
      'rid': '${currentUser.uid}_${widget.lawyerId}_${requestRef.id}',
      'userId': currentUser.uid,
      'lawyerId': widget.lawyerId,
      'lawyerName': lawyerName,
      'username': username,
      'title': _titleCont.text.trim(),
      'desc': _descriptionCont.text.trim(),
      'date': _selectedDate!.toIso8601String(),
      'time': _selectedTime!.format(context),
      'status': 'Pending',
      'timestamp': FieldValue.serverTimestamp(),
      'started?': false,
      'ended?': false,
      'fees': lawyerFees,
      'paid': false, // ✅ Explicitly added and guaranteed
    };

    try {
      await requestRef
          .set(request); // ✅ Using .set() to ensure false is written
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request: $e');
    }
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.grey[125],
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.97,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  Text(
                    'Book Consultation',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildTextField(
                        'Title',
                        _titleCont,
                        icon: Icons.edit,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Description',
                        _descriptionCont,
                        icon: Icons.description,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Select Date',
                        _dateController,
                        icon: Icons.calendar_today,
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        'Select Time',
                        _timeController,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _sendRequest,
                    child: const Text('Submit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
    String label,
    TextEditingController controller, {
    IconData? icon,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      maxLines: maxLines,
      style: GoogleFonts.lato(fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: const Color.fromARGB(255, 97, 97, 97))
            : null,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color.fromARGB(58, 224, 224, 224), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: const Color.fromARGB(0, 255, 255, 255), width: 1.2),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color ?? Colors.black87),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FC),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new, size: 17),
        ),
        backgroundColor: Colors.white,
        title: Text('Lawyer Details', style: GoogleFonts.lato()),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getinfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center();
          if (!snapshot.hasData || snapshot.data == null) return Center();

          final data = snapshot.data!.data()!;
          final int fees = data['fees'] ?? 20;
          final String exp = data['exp']?.toString() ?? '0';
          final String prov = data['province']?.toString() ?? 'Unknown';

          return LiquidPullToRefresh(
            onRefresh: _handleRefresh,
            showChildOpacityTransition: false,
            color: Color.fromARGB(255, 224, 191, 109),
            backgroundColor: Colors.white,
            animSpeedFactor: 2.0,
            height: 90,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(
                    color: Color.fromARGB(255, 243, 243, 243),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: (data['imageUrl'] != null &&
                                        data['imageUrl'].isNotEmpty)
                                    ? NetworkImage(data['imageUrl'])
                                    : AssetImage('assets/images/brad.webp')
                                        as ImageProvider,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      data['name'],
                                      style: GoogleFonts.lato(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      data['specialization'] ?? 'Unknown',
                                      style: GoogleFonts.lato(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.amber, size: 13),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${data['rating'] ?? 0.0} (${(data['cases'] ?? 0).toInt()} Reviews)",
                                          style: GoogleFonts.lato(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 13),
                          Divider(height: 24, thickness: 1.2),
                          _infoRow(
                            Icons.work_history,
                            'Years of Experience: $exp',
                          ),
                          _infoRow(Icons.location_city, 'Province: $prov'),
                          _infoRow(
                            Icons.monetization_on,
                            'Consultation Fee: \$$fees',
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          Text(
                            data['desc'] ?? 'No description available.',
                            style: GoogleFonts.lato(fontSize: 13, height: 1.5),
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _showRequestDialog,
                              icon: Icon(Icons.calendar_today),
                              label: Text('Book Consultation'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: GoogleFonts.lato(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Reviews',
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  LawyerReviewsWidget(lawyerId: data['uid']),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simulate network call
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {});
  }
}