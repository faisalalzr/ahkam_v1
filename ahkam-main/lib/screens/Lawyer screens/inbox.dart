import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class InboxScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F6F1),
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new, size: 17),
          ),
          backgroundColor: const Color(0xFFF9F6F1),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Inbox',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color.fromARGB(188, 0, 11, 36),
            labelColor: const Color.fromARGB(195, 0, 0, 0),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: "Ahkam Official"),
              Tab(text: "Interactions"),
            ],
          ),
        ),
        body: TabBarView(children: [_officialTab(), _interactionsTab()]),
      ),
    );
  }

  Widget _officialTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _notificationCard(
          title: "Upcoming changes to Ahkam subscription",
          subtitle:
              "Ahkam is committed to improving your legal experience with new features coming soon.",
          time: "55m ago",
        ),
        _notificationCard(
          title: "We value your feedback!",
          subtitle:
              "Tell us what you think and stand a chance to win a premium subscription.",
          time: "04-18",
        ),
        _notificationCard(
          title: "Try our new Pro features",
          subtitle:
              "Enjoy 10 free uses monthly. Go Pro for unlimited benefits.",
          time: "04-04",
        ),
      ],
    );
  }

  Widget _notificationCard({
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(
            255,
            2,
            0,
            108,
          ).withOpacity(0.1),
          child: const Icon(
            Icons.notifications_active,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.red),
            const SizedBox(height: 6),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _interactionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Wrap(
            spacing: 5,
            runSpacing: 8,
            children: [
              _filterChip("All", selected: true),
              _filterChip("Requests"),
              _filterChip("Likes"),
              _filterChip("Reviews"),
              _filterChip("Messages"),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bell, size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  "No notifications yet.",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, {bool selected = false}) {
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: selected ? Colors.white : const Color(0xFF4B3832),
        ),
      ),
      selected: selected,
      selectedColor: const Color.fromARGB(255, 0, 0, 0),
      backgroundColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) {
        selected = true;
      },
    );
  }
}
