import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Firestore {
  late CollectionReference<Map<String, dynamic>> _users;
  late Stream<QuerySnapshot> stream;
  late StreamSubscription listener;

  Firestore() {
    _users = FirebaseFirestore.instance.collection('users2');
    stream = _users.orderBy('localtime', descending: true).snapshots();
  }

  Future<void> create(Map<String, dynamic> data) async {
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
    await _users.doc(id).set(
          data,
          SetOptions(merge: true),
        );
    debugPrint('update:$id');
  }

  void listernerOn(Function f) {
    listener = stream.listen((event) => f(event));
    debugPrint('listener On');
  }

  void listernerOff() {
    listener.cancel();
    debugPrint('listener off');
  }
}
