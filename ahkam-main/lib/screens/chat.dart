import 'dart:io';
import 'package:ahakam_v8/services/chat_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/services.dart';

class Chat extends StatefulWidget {
  final String receiverID;
  final String receivername;
  final String rid;
  final String senderId;
  final String imageurl;

  const Chat({
    super.key,
    required this.receiverID,
    required this.receivername,
    required this.rid,
    required this.senderId,
    required this.imageurl,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isSending = false.obs;
  bool chatEnded = false;
  bool hasShownDialog = false;

  @override
  void initState() {
    super.initState();
    _checkIfChatEnded();
  }

  Future<void> _checkIfChatEnded() async {
    final requestSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('rid', isEqualTo: widget.rid)
        .limit(1)
        .get();

    final reviewSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('rid', isEqualTo: widget.rid)
        .where('reviewerId', isEqualTo: widget.senderId)
        .get();

    if (requestSnapshot.docs.isNotEmpty) {
      final docData = requestSnapshot.docs.first.data();
      if (docData['ended?'] == true) {
        setState(() {
          chatEnded = true;
        });

        // Show dialog only if user hasn't reviewed yet
        if (reviewSnapshot.docs.isEmpty) {
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => RatingDialog(
                lawyerId: widget.receiverID,
                rid: widget.rid,
                reviewerId: widget.senderId,
              ),
            );
          });
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty || chatEnded) return;
    _isSending.value = true;
    await _chatService.sendMessage(widget.senderId, widget.receiverID, message);
    _messageController.clear();
    _scrollToBottom();
    _isSending.value = false;
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> pickAndUploadFile() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery); // or .camera
      if (pickedFile == null) return;

      final file = File(pickedFile.path);
      final fileBytes = await file.readAsBytes();

      final fileName = DateTime.now().millisecondsSinceEpoch.toString() +
          "_" +
          pickedFile.name;

      final response = await Supabase.instance.client.storage
          .from('imagges')
          .uploadBinary(fileName, fileBytes,
              fileOptions: FileOptions(contentType: 'image/jpeg'));

      final imageUrl = Supabase.instance.client.storage
          .from('imagges')
          .getPublicUrl(fileName);
      List<String> ids = [widget.senderId, widget.receiverID]..sort();
      String chatroomId = ids.join('_');
      print('File uploaded. Public URL: $imageUrl');
      await FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatroomId)
          .collection("messages")
          .add({
        'senderId': widget.senderId,
        'receiverId': widget.receiverID,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'image',
        'message': imageUrl,
      });
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  Widget _buildMessageItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final isMe = data['senderId'] == widget.senderId;
    final message = data['message'] ?? '';
    final type = data['type'] ?? '';
    final time = _formatTimestamp(data['timestamp'] ?? 0);

    final isImageMessage = type == 'image' || message.contains('supabase.co');

    Widget content;
    if (isImageMessage) {
      content = GestureDetector(
        onTap: () => _launchURL(message),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            message,
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (type == 'file') {
      content = GestureDetector(
        onTap: () => _launchURL(message),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file, color: Colors.white),
            SizedBox(width: 6),
            Text("Document", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    } else {
      content = Text(
        message,
        style: TextStyle(color: isMe ? Colors.white : Colors.black),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final hour = dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$min $period';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } else {
      Get.snackbar("Error", "Cannot open the link.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.imageurl)),
            SizedBox(width: 10),
            Text(widget.receivername),
          ],
        ),
        leading: BackButton(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatService.getMessages(
                widget.senderId,
                widget.receiverID,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                    controller: _scrollController,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      if (index == docs.length - 1) {
                        Future.delayed(
                            Duration(milliseconds: 100), _scrollToBottom);
                      }
                      return _buildMessageItem(docs[index]);
                    });
              },
            ),
          ),
          chatEnded
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "This consultation has ended.",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.document_scanner),
                        onPressed: pickAndUploadFile,
                      ),
                      Obx(() {
                        return IconButton(
                          icon: Icon(Icons.send),
                          onPressed: _isSending.value ? null : _sendMessage,
                        );
                      }),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  final String lawyerId;
  final String rid;
  final String reviewerId;

  const RatingDialog({
    Key? key,
    required this.lawyerId,
    required this.rid,
    required this.reviewerId,
  }) : super(key: key);

  @override
  _RatingDialogState createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  Future<void> _submitRating() async {
    if (_rating == 0 || _reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide a rating and a review.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reviewsRef = FirebaseFirestore.instance.collection('reviews');
      final lawyerRef =
          FirebaseFirestore.instance.collection('account').doc(widget.lawyerId);

      // Add the review document
      await reviewsRef.doc('${widget.rid}_${widget.reviewerId}').set({
        'lawyerId': widget.lawyerId,
        'rid': widget.rid,
        'reviewerId': widget.reviewerId,
        'rating': _rating,
        'review': _reviewController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get the lawyer document snapshot
      final snapshot = await lawyerRef.get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lawyer data not found')),
        );
        return;
      }

      final data = snapshot.data()!;
      final int casesFinished = (data['cases'] ?? 0) as int;
      final double avgRating = (data['rating'] ?? 0.0).toDouble();

      final int newCount = casesFinished + 1;
      final double newAverage =
          ((avgRating * casesFinished) + _rating) / newCount;

      // Update the lawyer stats
      await lawyerRef.update({
        'cases': newCount,
        'rating': double.parse(newAverage.toStringAsFixed(2)),
      });

      Navigator.of(context).pop();
    } catch (e) {
      print('Error submitting review: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review.')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color.fromARGB(255, 0, 0, 0); // soft brown
    final backgroundColor = Color.fromARGB(255, 255, 250, 243); // soft beige

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: backgroundColor,
      contentPadding: EdgeInsets.all(20),
      title: Text(
        'Leave a Review',
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              itemCount: 5,
              itemSize: 32,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amberAccent),
              onRatingUpdate: (rating) => setState(() => _rating = rating),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _reviewController,
              maxLines: 4,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Write your review...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Text(
                      'Submit',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
