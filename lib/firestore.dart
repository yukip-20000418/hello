import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore {
  final users = FirebaseFirestore.instance.collection('users2');

  Future<void> create(Map<String, dynamic> data) async {
    await users.add(data);
  }

  Future<void> read() async {
    final ss = await users.get();

    for (var doc in ss.docs) {
      debugPrint('${doc.id} -> ${doc.data()}');
    }
  }

  // Future<void> update() async {
  //   await users.doc('x').set({
  //     'name': 'takemoto',
  //     'age': 24,
  //     'year': 1999,
  //   }, SetOptions(merge: true));
  // }
}
