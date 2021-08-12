import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  @override
  Widget build(BuildContext context) {
    String _strDevice = 'Welcome to sensor page';
    _strDevice = _strDevice + '\nMac Address: ${widget.device.id}';
    _strDevice = _strDevice + '\nDevice Name: ${widget.device.name}';
    return Scaffold(
        appBar: AppBar(
          title: Text('sensor page'),
        ),
        body: Center(child: Text(_strDevice)));
  }
}
