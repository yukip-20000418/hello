import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Firestore {
  late CollectionReference<Map<String, dynamic>> _users;
  late Stream<QuerySnapshot> stream;
  late StreamSubscription listener;

  Firestore() {
    _users = FirebaseFirestore.instance.collection('users2');
    stream = _users.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> create(Map<String, dynamic> data) async {
    data['timestamp'] = FieldValue.serverTimestamp();
    final ref = await _users.add(data);
    debugPrint('create:$data, id:${ref.id}');
  }

  Future<void> read() async {
    final ss = await _users.orderBy('timestamp', descending: true).get();
    for (var doc in ss.docs) {
      debugPrint('${doc.id} -> ${doc.data()}');
    }
  }

  Future<void> delete(String id) async {
    await _users.doc(id).delete();
    debugPrint('delete:$id');
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    data['timestamp'] = FieldValue.serverTimestamp();
    await _users.doc(id).set(
          data,
          SetOptions(merge: true),
        );
    debugPrint('update:$id');
  }

  void listernerOn() {
    listener = stream.listen((event) {
      for (var change in event.docChanges) {
        final data = change.doc.data()! as Map<String, dynamic>;
        final dt1 = data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : DateTime(2100);
        final dt2 = (data['localtime'] as Timestamp).toDate();
        debugPrint('[${change.type}] $dt1, $dt2 : ${data['name']} : ${data['counter']}');
      }
    });

    debugPrint('listener On');
  }

  void listernerOff() {
    listener.cancel();
    debugPrint('listener off');
  }
}
