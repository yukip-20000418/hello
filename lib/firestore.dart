import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore {
  final db = FirebaseFirestore.instance;

  Future<void> create(int counter) async {
    await db.collection('users').add({
      'name': 'moriya',
      'age': 21,
      'year': 2000,
      'counter': counter,
    });
  }

  Future<void> read() async {
    final ss = await db.collection('users').get();

    for (var doc in ss.docs) {
      debugPrint('${doc.id} -> ${doc.data()}');
    }
  }

  Future<void> update() async {
    await db.collection('users').doc('x').set({
      'name': 'takemoto',
      'age': 24,
      'year': 1999,
    }, SetOptions(merge: true));
  }
}
