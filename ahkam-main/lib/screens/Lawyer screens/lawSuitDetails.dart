import 'package:ahakam_v8/screens/Lawyer%20screens/lawyerMessages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Lawsuit extends StatefulWidget {
  const Lawsuit({Key? key, required this.rid}) : super(key: key);
  final String rid;

  @override
  State<Lawsuit> createState() => _LawsuitState();
}

class _LawsuitState extends State<Lawsuit> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getRequestStream() {
    return _firestore
        .collection('requests')
        .where('rid', isEqualTo: widget.rid)
        .limit(1)
        .snapshots();
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat.yMMMMd().format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String formatTimestamp(Timestamp ts) {
    try {
      final date = ts.toDate();
      return DateFormat.yMMMMd().add_jm().format(date);
    } catch (_) {
      return ts.toString();
    }
  }

  Future<void> updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': newStatus,
      });
    } catch (e) {
      debugPrint('Error updating status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update status.')),
        );
      }
    }
  }

  Future<void> createPaymentForLawyer({
    required String lawyerId,
    required String clientId,
    required String requestId,
    required int fee,
  }) async {
    try {
      await _firestore.collection('payments').add({
        'lawyerId': lawyerId,
        'clientId': clientId,
        'requestId': requestId,
        'fee': fee,
        'date': DateTime.now().toIso8601String(),
        'status': 'completed',
      });
    } catch (e) {
      debugPrint('Error creating payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Case Review',
          style: GoogleFonts.openSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getRequestStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No request found.'));
          }

          final doc = snapshot.data!.docs.first;
          final requestId = doc.id;
          final request = doc.data() as Map<String, dynamic>;
          final status = request['status'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _section('Client', request['username']),
                      _section('Title', request['title']),
                      _section('Description', request['desc']),
                      _section('Fees', '\$${request['fees']}'),
                      _section('Date', formatDate(request['date'])),
                      _section('Time', request['time']),
                      _section('Status:', status),
                      _section(
                        'Sent At',
                        formatTimestamp(request['timestamp']),
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1),
                const SizedBox(height: 30),
                if (status == 'Accepted' || status == 'Rejected')
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                        setState(() {});
                      },
                      label: const Text(
                        'Back',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 58, 112),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            await updateRequestStatus(requestId, 'Accepted');
                            await createPaymentForLawyer(
                              lawyerId: request['lawyerId'],
                              clientId: request['userId'],
                              requestId: request['rid'],
                              fee: request['fees'],
                            );
                            if (mounted) {}
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Accept'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.teal.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await _firestore
                                .collection('requests')
                                .doc(requestId)
                                .delete();
                            if (mounted) {
                              Get.back();
                              Get.snackbar(
                                'Dismissed',
                                'The case has been removed.',
                                backgroundColor: Colors.red.shade50,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                            }
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Reject'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _section(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
