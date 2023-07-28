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
      title: 'OPEN-TEST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'firestore'),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  // const MyHomePage({super.key, required this.title});

  // final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final _db = Firestore();
  late Firestore _db;
  // int flg = 0;
  // dynamic listener;
  late TextEditingController _counterCtl;
  late TextEditingController _nameCtl;

  @override
  void initState() {
    super.initState();
    _counterCtl = TextEditingController(text: '6');
    _nameCtl = TextEditingController(text: 'taro');
    _db = Firestore();
    _db.listernerOn(_change);
    // listener = _db.stream.listen((event) => _change(event));
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _counterCtl.dispose();
    _db.listernerOff();
    super.dispose();
  }

  void _change(QuerySnapshot event) {
    for (var change in event.docChanges) {
      final data = change.doc.data()! as Map<String, dynamic>;
      final dt1 = data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime(2100);
      final dt2 = (data['localtime'] as Timestamp).toDate();
      debugPrint(
          '[${change.type}] $dt1, $dt2 : ${data['name']} : ${data['counter']}');
    }
  }

  // void _listen() {
  //   debugPrint('$listener');
  //   if (flg == 0) {
  //     flg = 1;
  //     debugPrint('listener start');
  //     listener = _db.stream.listen((event) => _change(event));
  //   } else {
  //     flg = 0;
  //     debugPrint('listener cancel');
  //     listener.cancel();
  //   }
  // }

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
      'timestamp': FieldValue.serverTimestamp(),
      'localtime': DateTime.now(),
    });
  }

  void _update(id) {
    _db.update(id, {
      'counter': _counterCtl.text,
      'localtime': DateTime.now(),
    });
  }

  void _delete(id) {
    _db.delete(id);
  }

  // void _read() {
  //   _db.read();
  // }

  Widget doc(DocumentSnapshot document) {
    final data = document.data()! as Map<String, dynamic>;

    final dt1 = data['timestamp'] is Timestamp
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime(2100);
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
          color: const Color.fromRGBO(128, 0, 0, 0.1),
          child: Text('${document.id} : ${data.toString()}'),
        ),
      ],
    );

    return Column(
      children: [
        const SizedBox(height: 1),
        Container(
          color: const Color.fromRGBO(128, 0, 0, 0.1),
          child: Row(
            children: [
              Expanded(child: record),
              const SizedBox(width: 1),
              IconButton(
                onPressed: () => _update(document.id),
                icon: const Icon(Icons.update),
              ),
              IconButton(
                onPressed: () => _delete(document.id),
                icon: const Icon(Icons.delete),
              ),
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
        return ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return doc(document);
          }).toList(),
        );
      },
    );
  }

  // Widget buttonBar() {
  //   return ButtonBar(
  //     alignment: MainAxisAlignment.center,
  //     children: [
  //       ElevatedButton(onPressed: _create, child: const Text('create')),
  //       ElevatedButton(onPressed: _read, child: const Text('read')),
  //       ElevatedButton(onPressed: _listen, child: const Text('listen')),
  //     ],
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('FIRESTORE ACCESS'),
        // title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                NameField(nameCtl: _nameCtl),
                const SizedBox(width: 20),
                CounterField(counterCtl: _counterCtl),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _create,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('create'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // buttonBar(),
            // const SizedBox(height: 10),
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

class NameField extends StatelessWidget {
  const NameField({
    super.key,
    required TextEditingController nameCtl,
  }) : _nameCtl = nameCtl;

  final TextEditingController _nameCtl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'name',
          prefixIcon: Icon(Icons.face),
        ),
        controller: _nameCtl,
      ),
    );
  }
}

class CounterField extends StatelessWidget {
  const CounterField({
    super.key,
    required TextEditingController counterCtl,
  }) : _counterCtl = counterCtl;

  final TextEditingController _counterCtl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'counter',
          prefixIcon: Icon(Icons.pin),
        ),
        controller: _counterCtl,
      ),
    );
  }
}
