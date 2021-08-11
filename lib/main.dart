import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart'; // use ble

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iTag Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (context, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) {
              return FindItagScreen();
            } else {
              return BtOffScreen();
            }
          }),
    );
  }
}

class BtOffScreen extends StatelessWidget {
  const BtOffScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Off'),
      ),
      body: Center(child: Text('Bluetooth Off')),
    );
  }
}

class FindItagScreen extends StatefulWidget {
  const FindItagScreen({Key? key}) : super(key: key);

  @override
  _FindItagScreenState createState() => _FindItagScreenState();
}

class _FindItagScreenState extends State<FindItagScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching iTag ...'),
      ),
      body: Center(child: Text('Searching iTag ...')),
    );
  }
}
