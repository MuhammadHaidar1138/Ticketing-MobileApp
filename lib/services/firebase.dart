// services/firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference ticketsCollection = FirebaseFirestore.instance.collection("Ticket");

  Stream<QuerySnapshot> getTickets() {
    final streamTickets = ticketsCollection.orderBy("tanggal", descending: true).snapshots();
    return streamTickets;
  }
}