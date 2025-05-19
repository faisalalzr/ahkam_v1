import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ConsultationDetailsScreen extends StatelessWidget {
  final String rid;
  final DocumentReference<Map<String, dynamic>>? requestRef;
  final VoidCallback onEnded;

  const ConsultationDetailsScreen({
    super.key,
    required this.rid,
    required this.requestRef,
    required this.onEnded,
  });

  Future<Map<String, dynamic>?> _loadRequestDetails() async {
    if (requestRef == null) return null;
    final doc = await requestRef!.get();
    return doc.data();
  }

  Future<void> _confirmEndConsultation(BuildContext context) async {
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          "End Consultation",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        content: Text(
          "Are you sure you want to end this consultation?",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              "End",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldEnd == true) {
      await requestRef?.update({'ended?': true});
      onEnded(); // Notify parent
      Get.back(); // Return to chat screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Consultation Details",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadRequestDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text("No consultation data found."));
          }

          final String client = data['username'] ?? 'N/A';
          final String issue = data['title'] ?? 'N/A';
          final String desc = data['desc'] ?? 'N/A';
          final String date = data['date'] ?? 'N/A';
          final String time = data['time'] ?? 'N/A';
          final Timestamp? startTimestamp = data['timestamp'];
          final DateTime start = startTimestamp?.toDate() ?? DateTime.now();
          final Duration duration = DateTime.now().difference(start);
          final String formattedDuration = _formatDuration(duration);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow("Client", client),
                        _infoRow("Issue", issue),
                        _infoRow("description", desc),
                        _infoRow("Scheduled Date", date.substring(0, 10)),
                        _infoRow("Scheduled Time", time),
                        _infoRow(
                          "Started At",
                          DateFormat('MMM d, yyyy – hh:mm a').format(start),
                        ),
                        _infoRow("Duration", formattedDuration),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmEndConsultation(context),
                    icon: Icon(Icons.stop_circle),
                    label: Text("End Consultation"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
                children: [
                  TextSpan(
                    text: "$label:  ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return "${hours > 0 ? "$hours hr " : ""}$minutes min";
  }
}
