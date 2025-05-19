import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewTile extends StatelessWidget {
  final Map<String, dynamic> reviewData;
  final String reviewerName;
  final String? reviewerImageUrl;

  const ReviewTile({
    super.key,
    required this.reviewData,
    required this.reviewerName,
    this.reviewerImageUrl,
    required Text title,
    required Text subtitle,
    required Row trailing,
  });

  @override
  Widget build(BuildContext context) {
    final rating = reviewData['rating'] ?? 0.0;
    final comment = reviewData['review'] ?? '';
    final timestamp = reviewData['timestamp'] as Timestamp;
    final formattedDate = DateFormat.yMMMMd().format(timestamp.toDate());

    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      reviewerImageUrl != null
                          ? NetworkImage(reviewerImageUrl!)
                          : const AssetImage('assets/default_user.png')
                              as ImageProvider,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < rating.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }
}
