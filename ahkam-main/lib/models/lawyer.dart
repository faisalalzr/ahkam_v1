import 'package:ahakam_v8/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Lawyer extends Account {
  @override
  final String? uid;
  @override
  final String? name;
  @override
  final String email;
  final String? specialization;
  final double? rating;
  final String? province;
  @override
  final String? number;
  final String? licenseNO;
  final int? exp;
  final int? cases;

  @override
  bool? isLawyer;
  final String? desc;
  final int? fees;
  final String? imageUrl;

  Lawyer({
    this.uid,
    this.name,
    required this.email,
    this.cases,
    this.specialization,
    this.rating,
    this.province,
    this.number,
    this.licenseNO,
    this.exp,
    this.isLawyer,
    this.desc,
    this.fees,
    this.imageUrl,
  }) : super(email: email);

  @override
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'specialization': specialization,
      'rating': rating,
      'province': province,
      'number': number,
      'licenseNO': licenseNO,
      'exp': exp,
      'isLawyer': isLawyer,
      'desc': desc,
      'fees': fees,
      'imageUrl': imageUrl,
      'cases': cases
    };
  }

  factory Lawyer.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Lawyer(
        uid: doc.id, // Use Firestore document ID as uid
        name: map['name'] ?? 'Unknown',
        email: map['email'] ?? '',
        specialization: map['specialization'],
        rating:
            (map['rating'] as num?)?.toDouble() ?? 0.0, // Default 0.0 if null
        province: map['province'],
        number: map['number'],
        licenseNO: map['licenseNO'],
        exp: map['exp'] ?? 0,
        isLawyer: map['isLawyer'] ?? false,
        desc: map['desc'] ?? '',
        fees: map['fees'] ?? '',
        imageUrl: map['imageUrl'] ?? '',
        cases: map['cases'] ?? 0);
  }

  static final CollectionReference lawyerCollection =
      FirebaseFirestore.instance.collection('account');

  @override
  Future<void> addToFirestore() async {
    // Use uid as the document ID
    await lawyerCollection.doc(uid).set(toMap());
  }

  /// **Fetch Top-Rated Lawyers**
  static Future<List<Lawyer>> getTopLawyers({int limit = 3}) async {
    QuerySnapshot querySnapshot = await lawyerCollection
        .where('isLawyer', isEqualTo: true)
        //.orderBy('rating', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => Lawyer.fromFirestore(doc)).toList();
  }

  static fromMap(Map<String, dynamic> data) {}
}
