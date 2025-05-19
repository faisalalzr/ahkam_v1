import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shimmer/shimmer.dart';

class LawyerReviewsWidget extends StatelessWidget {
  final String lawyerId;

  const LawyerReviewsWidget({super.key, required this.lawyerId});

  @override
  Widget build(BuildContext context) {
    String timeAgo(Timestamp timestamp) {
      final now = DateTime.now();
      final date = timestamp.toDate();
      final diff = now.difference(date);

      if (diff.inSeconds < 60) return 'just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo ago';
      return '${(diff.inDays / 365).floor()}y ago';
    }

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('reviews')
              .where('lawyerId', isEqualTo: lawyerId)
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoader();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text("No reviews yet.")),
          );
        }

        final reviews = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final review = reviews[index];
            final data = review.data() as Map<String, dynamic>;

            return FutureBuilder<DocumentSnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('account')
                      .doc(data['reviewerId'])
                      .get(),
              builder: (context, userSnapshot) {
                final Timestamp timestamp = data['timestamp'];
                final String timeAgoText = timeAgo(timestamp);

                if (!userSnapshot.hasData) return SizedBox.shrink();

                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                if (userData == null) return SizedBox.shrink();

                final double rating = (data['rating'] ?? 0).toDouble();
                final String reviewText = data['review'] ?? '';

                return Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            userData['imageUrl'] != null &&
                                    userData['imageUrl'].isNotEmpty
                                ? NetworkImage(userData['imageUrl'])
                                : AssetImage('assets/images/brad.webp')
                                    as ImageProvider,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userData['name'] ?? 'Anonymous',
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  timeAgoText,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            RatingBarIndicator(
                              rating: rating,
                              itemBuilder:
                                  (context, index) =>
                                      Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            SizedBox(height: 8),
                            Text(
                              reviewText,
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(radius: 26, backgroundColor: Colors.grey[300]),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: 100, color: Colors.grey),
                      SizedBox(height: 6),
                      Container(height: 12, width: 150, color: Colors.grey),
                      SizedBox(height: 6),
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
