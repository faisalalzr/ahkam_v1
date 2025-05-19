import 'dart:io';
import 'package:ahakam_v8/screens/Lawyer%20screens/endchat.dart';
import 'package:ahakam_v8/services/auth_service.dart';
import 'package:ahakam_v8/services/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Lawyerchat extends StatefulWidget {
  final String receiverID;
  final String receivername;
  final String rid;
  final String senderId;
  final String imgUrl;

  const Lawyerchat({
    super.key,
    required this.receiverID,
    required this.receivername,
    required this.rid,
    required this.senderId,
    required this.imgUrl,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Lawyerchat> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RxBool _isSendingMessage = false.obs;

  bool hasEnded = false;
  bool isLawyer = true;
  DocumentReference<Map<String, dynamic>>? requestRef;

  @override
  void initState() {
    super.initState();
    _loadRequestStatus();
  }

  Future<void> _loadRequestStatus() async {
    final userId = _authService.getCurrentUser()?.uid;
    if (userId == null) return;

    final query = await FirebaseFirestore.instance
        .collection('requests')
        .where('rid', isEqualTo: widget.rid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      requestRef = doc.reference;

      setState(() {
        hasEnded = doc['ended?'] ?? false;
        isLawyer = true;
      });
    }
  }

  Future<void> _sendMessage() async {
    if (hasEnded) {
      //Get.snackbar("Consultation Ended", "You cannot send messages anymore.");
      return;
    }

    String message = _messageController.text.trim();
    if (message.isEmpty) return;

    _isSendingMessage.value = true;
    try {
      await _chatService.sendMessage(
        widget.senderId,
        widget.receiverID,
        message,
      );
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      Get.snackbar("Error", "Failed to send message: $e");
    } finally {
      _isSendingMessage.value = false;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.imgUrl),
            ),
            SizedBox(width: 10),
            Text(
              widget.receivername,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {
              Get.to(
                transition: Transition.rightToLeft,
                () => ConsultationDetailsScreen(
                  rid: widget.rid,
                  requestRef: requestRef,
                  onEnded: () {
                    setState(() {
                      hasEnded = true;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // if (isLawyer && !hasEnded)
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: ElevatedButton.icon(
          //       onPressed: () async {
          //         if (requestRef != null) {
          //           await requestRef!.update({'ended?': true});
          //           setState(() {
          //             hasEnded = true;
          //           });
          //           Get.snackbar(
          //             "Consultation Ended",
          //             "The chat is now closed.",
          //           );
          //         }
          //       },
          //       icon: Icon(Icons.stop_circle),
          //       label: Text("End Consultation"),
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.red,
          //         foregroundColor: Colors.white,
          //       ),
          //     ),
          //   ),
          Expanded(child: buildMessageList()),
          buildMessageInputField(),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    User? currentUser = _authService.getCurrentUser();
    if (currentUser == null) {
      return Center(child: Text("Error: User not found"));
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _chatService.getMessages(widget.senderId, widget.receiverID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No messages yet."));
        }

        List<DocumentSnapshot<Map<String, dynamic>>> messageDocs =
            snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(vertical: 10),
          itemCount: messageDocs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messageDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data();
    if (data == null) return SizedBox.shrink();
    bool isMe = data["senderId"] == widget.senderId;
    Timestamp timestamp = data["timestamp"];
    String formattedTime = formatTimestamp(timestamp);
    final message = data['message'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1E3A5F) : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.endsWith('.jpg') ||
                message.endsWith('.png') ||
                message.endsWith('.jpeg'))
              Image.network(message, height: 150)
            else if (message.startsWith('http'))
              GestureDetector(
                onTap: () => launchUrl(
                  Uri.parse(message),
                  mode: LaunchMode.inAppWebView,
                ),
                child: Text(
                  "View Document",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.blue,
                  ),
                ),
              )
            else
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : const Color(0xFF1E3A5F),
                ),
              ),
            SizedBox(height: 5),
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : const Color(0xFF1E3A5F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    var hourtime = dateTime.hour;
    if (hourtime > 12) {
      return "${dateTime.hour - 12}:${dateTime.minute.toString().padLeft(2, '0')}";
    }
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  Widget buildMessageInputField() {
    if (hasEnded) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          "This consultation has ended. You can no longer send messages.",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Message...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 18,
            child: IconButton(
              icon: Icon(
                Icons.document_scanner,
                size: 18,
                color: const Color(0xFF1E3A5F),
              ),
              onPressed: () async {},
            ),
          ),
          SizedBox(width: 4),
          Obx(() {
            return GestureDetector(
              onTap: _isSendingMessage.value ? null : _sendMessage,
              child: CircleAvatar(
                backgroundColor: const Color(0xFF1E3A5F),
                radius: 17,
                child: Icon(Icons.send, color: Colors.white, size: 17),
              ),
            );
          }),
        ],
      ),
    );
  }
}
