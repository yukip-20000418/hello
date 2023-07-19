import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore {
  // final _users = FirebaseFirestore.instance.collection('users');
  late CollectionReference<Map<String, dynamic>> _users;
  late Stream<QuerySnapshot> stream;
  var a = 100;

  Firestore() {
    _users = FirebaseFirestore.instance.collection('users');
    stream = _users.orderBy('timestamp', descending: false).snapshots();
  }

  Future<void> create(Map<String, dynamic> data) async {
    data['counter'] += a;
    await _users.add(data);
    debugPrint('add : $data, a:$a');
  }

  Future<void> read() async {
    final ss = await _users
        .orderBy(
          'timestamp',
          descending: false,
        )
        .get();

    for (var doc in ss.docs) {
      debugPrint('${doc.id} -> ${doc.data()}');
    }
  }

  // Future<void> update() async {
  //   await _users.doc('x').set({
  //     'name': 'takemoto',
  //     'age': 24,
  //     'year': 1999,
  //   }, SetOptions(merge: true));
  // }
}
