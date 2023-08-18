import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './firebase_options.dart';
import './firestore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      title: 'OPEN-TEST',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Firestore _db;
  late TextEditingController _counterCtl;
  late TextEditingController _nameCtl;

  @override
  void initState() {
    super.initState();
    _counterCtl = TextEditingController(text: '100');
    _nameCtl = TextEditingController(text: 'no-name');
    _db = Firestore();
    _db.listernerOn();
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _counterCtl.dispose();
    _db.listernerOff();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counterCtl.text = (int.parse(_counterCtl.text) + 1).toString();
    });
    debugPrint('count-up:${_counterCtl.text}');
  }

  void _create() {
    _db.create({
      'name': _nameCtl.text,
      'counter': _counterCtl.text,
      'localtime': DateTime.now(),
    });
  }

  void _update(id) {
    _db.update(id, {
      'counter': _counterCtl.text,
    });
  }

  void _delete(id) {
    _db.delete(id);
  }

  Widget doc(DocumentSnapshot document) {
    final data = document.data()! as Map<String, dynamic>;

    final dt1 = data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : DateTime(2100);
    final dt2 = (data['localtime'] as Timestamp).toDate();

    var record = Column(
      children: [
        Row(
          children: [
            Expanded(flex: 3, child: Text('$dt1')),
            Expanded(flex: 3, child: Text('$dt2')),
            Expanded(child: Text('${data['name']}')),
            Expanded(child: Text('${data['counter']}')),
          ],
        ),
        Container(
          width: double.infinity,
          color: const Color.fromRGBO(128, 128, 200, 0.1),
          child: Text('${document.id} : ${data.toString()}'),
        ),
      ],
    );

    return Column(
      children: [
        const SizedBox(height: 1),
        Container(
          color: const Color.fromRGBO(100, 100, 200, 0.1),
          child: Row(
            children: [
              Expanded(child: record),
              const SizedBox(width: 1),
              IconButton(onPressed: () => _update(document.id), icon: const Icon(Icons.update)),
              IconButton(onPressed: () => _delete(document.id), icon: const Icon(Icons.delete)),
            ],
          ),
        ),
      ],
    );
  }

  Widget list() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('wait!!!!');
          return const Center(child: Text('wait!!!'));
        }
        if (snapshot.hasError) {
          debugPrint('error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return doc(document);
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var wrapA = Wrap(
      alignment: WrapAlignment.start,
      runAlignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'name', prefixIcon: Icon(Icons.face)),
            controller: _nameCtl,
          ),
        ),
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'counter', prefixIcon: Icon(Icons.pin)),
            controller: _counterCtl,
          ),
        ),
      ],
    );

    var wrapB = Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.spaceEvenly,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10.0,
      runSpacing: 10.0,
      children: [
        ElevatedButton.icon(onPressed: _create, icon: const Icon(Icons.create_outlined), label: const Text('create')),
        ElevatedButton.icon(onPressed: _db.listernerOff, icon: const Icon(Icons.notifications_off_outlined), label: const Text('test-listener-off')),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FIRESTORE ACCESS'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              runAlignment: WrapAlignment.spaceEvenly,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 20.0,
              runSpacing: 20.0,
              children: [wrapA, wrapB],
            ),
            const SizedBox(height: 20),
            Expanded(child: list()),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}
