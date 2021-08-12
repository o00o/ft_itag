import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  bool isReady = false; // isReady

  @override
  void initState() {
    super.initState();

    connectToDevice();
  }

  connectToDevice() async {
    // if (widget.device == null) {
    //   _Pop();
    //   return;
    // }

    new Timer(const Duration(seconds: 15), () {
      // ภายในนี้ จะถูกเรียกจาก callback func. ของ Timer เมื่อเวลาผ่านไป 15 sec
      // ถ้า มันยัง connect ไม่ได้ จะทำการ disconnect bluetooth device แล้วย้อนกับไปหน้าก่อนหน้า
      // ต้อง disconnect ก่อนกลับหน้า เดิม bc. อาจเกิดกรณีมีปัญหาถ้า มัน connect กันได้ ระหว่าง/หลังจากย้อนกลับไปหน้าเดิม เราจะไม่รู้ว่ามัน connect กันอยู่
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    // await widget.device!.connect(); // connect bluetooth device
    await widget.device.connect(); // connect bluetooth device
    print('Device (Mac Addr.: ${widget.device.id}) connected successful');
    isReady = true;
    // discoverServices();
  }

  disconnectFromDevice() {
    // if (widget.device == null) {
    //   // ถ้าไม่มี device ตั้งแต่แรก ก็ออกได้เลย ไม่ต้อง disconnect แล้ว
    //   _Pop();
    //   return;
    // }

    // widget.device!.disconnect();
    widget.device.disconnect();
    print('Device (Mac Addr.: ${widget.device.id}) was disconnected');
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

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
