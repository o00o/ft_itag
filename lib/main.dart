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
              return FindItagPage();
            } else {
              return BtOffPage();
            }
          }),
    );
  }
}

class BtOffPage extends StatelessWidget {
  const BtOffPage({Key? key}) : super(key: key);

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

class FindItagPage extends StatefulWidget {
  const FindItagPage({Key? key}) : super(key: key);

  @override
  _FindItagPageState createState() => _FindItagPageState();
}

class _FindItagPageState extends State<FindItagPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Searching iTag ...'),
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (context, snapshot) {
                return Column(
                    children: snapshot.data!
                        .map(
                            // เอาข้อมูล scanResult มาทำเป็น List ของ Widget Text แสดงค่า bt device id + name ที่scan เจอ
                            (r) => Text('id: ${r.device.id},  name: ${r.device.name}'))
                        .toList());
              },
            )
          ],
        ),
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: () {
          FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
        },
      ),
    );
  }
}
