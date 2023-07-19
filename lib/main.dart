import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'firestore.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();
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
      title: 'DEBUG TEST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'DEBUG'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final _db = Firestore();
  int flg = 0;
  var listener;

  void _listen() {
    if (flg == 0) {
      flg = 1;
      debugPrint('listener start');
      listener = _db.stream.listen((event) {
        for (var change in event.docChanges) {
          final data = change.doc.data()! as Map<String, dynamic>;
          if (data['timestamp'] is Timestamp) {
            final Timestamp t = data['timestamp'];
            final DateTime d = t.toDate();
            final dt = d;
            // final dt = data['timestamp'].toDate();
            debugPrint('!!! ${change.type}: $dt, ${data['name']}');
          }
        }
      });
    } else {
      debugPrint('listener cancel a: $listener');
      listener.cancel();
      flg = 0;
      debugPrint('listener cancel b: $listener');
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
    debugPrint('count:$_counter, a:${_db.a}');
    _db.a++;
  }

  void _create() {
    _db.create({
      'name': 'habu',
      'counter': _counter,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _read() {
    _db.read();
  }

  Widget list() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.stream,
      builder: (context, snapshot) {
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            final data = document.data()! as Map<String, dynamic>;
            if (data['timestamp'] is Timestamp) {
              final dt = data['timestamp'].toDate();
              return Text('$dt : ${data['name']} : ${data['counter']}');
            } else {
              return Text(data.toString());
            }
            // return Text('$dt : ${data['name']} : ${data['counter']}');
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _create,
                  child: const Text('create'),
                ),
                ElevatedButton(
                  onPressed: _read,
                  child: const Text('read'),
                ),
                ElevatedButton(
                  onPressed: _listen,
                  child: const Text('listen'),
                ),
              ],
            ),
            Expanded(
              child: list(),
            ),
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
