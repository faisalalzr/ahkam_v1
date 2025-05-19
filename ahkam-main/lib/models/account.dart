import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String? uid;
  final String? name;
  final String email;
  bool? isLawyer;
  final String? number;
  String? imageUrl;

  Account({
    this.uid,
    this.name,
    required this.email,
    this.number,
    this.isLawyer,
    this.imageUrl,
  });

  factory Account.fromMap(Map<String, dynamic> data) {
    return Account(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      number: data['number'] ?? '',
      isLawyer: data['isLawyer'] ?? false,
      imageUrl: data['imageUrl'] ?? '', // Add imageUrl here
    );
  }

  // A method to convert an Account object into a map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'number': number,
      'isLawyer': isLawyer,
      'imageUrl': imageUrl, // Add imageUrl here
    };
  }

  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('account');

  Future<void> addToFirestore() async {
    // When adding, use the UID as the document ID
    await userCollection.doc(uid).set(toMap());
  }

  Future<List<Account>> getUsers() async {
    QuerySnapshot snap = await userCollection.get();
    return snap.docs
        .map((doc) => Account.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Update a user's details in Firestore
  Future<void> updateInFirestore() async {
    if (uid != null && uid!.isNotEmpty) {
      await userCollection.doc(uid).update(toMap());
    }
  }

  // Delete a user from Firestore
  Future<void> deleteFromFirestore() async {
    if (uid != null && uid!.isNotEmpty) {
      await userCollection.doc(uid).delete();
    }
  }
}
