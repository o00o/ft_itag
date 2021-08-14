import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:vibration/vibration.dart'; // use vibration


Timer? timerVibrate; // timer used for control toggle start-stop vibrate
bool flagStartVibrate = false;
bool vibrateStatus = false;
var notifyStreamPressingItag = null;

void vibrateAction() {
  vibrateStatus = !vibrateStatus;
  if (vibrateStatus) {
    // vibrate with pattern (wait 200ms, vibrate 1s, wait 200ms, vibrate 1s)
    Vibration.vibrate(pattern: [200, 1000, 200, 1000]);
  }
}

class SensorPage extends StatefulWidget {
  const SensorPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _SensorPageState createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  bool isReady = false; // isReady: true: finish discover available services
  bool _isCallItag = false;
  BluetoothCharacteristic? _btCharCallItag;
  BluetoothCharacteristic? _btCharNotifyPressItagBt;
  // Stream<List<int>>? _streamItagPressStatus;
  // Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  void initState() {
    super.initState();

    connectToDevice();
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    timerVibrate?.cancel();

    if (notifyStreamPressingItag != null) {
      notifyStreamPressingItag.cancel();
      print('cancel notifyStreamPressingItag');
    }

    // if (_btCharNotifyPressItagBt != null) {
    //   _btCharNotifyPressItagBt!.value.listen((value) { //ok
    //   }).cancel();
    //   print('cancel notify listen');
    // }


    // if (_btCharNotifyPressItagBt != null) {
    //   await _btCharNotifyPressItagBt!.setNotifyValue(false);
    //   print('cancel notify pressing iTag button');
    // }

    await widget.device.disconnect();
    print('disconnect ble');

    print('pop sensor_page');
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

    // //// try to get rssi simultaneously, BUT still work as expect --> ng
    // FlutterBlue.instance.startScan();
    // var subscription = FlutterBlue.instance.scanResults.listen((scanResults) {
    //   print('new scan result');
    //   scanResults.forEach((scanResult) {
    //     if (scanResult.device.id == widget.device.id) {
    //       print('rssi ${widget.device.id} found! rssi: ${scanResult.rssi}');
    //     }
    //   });
    // });

    discoverServices();


    setState(() {
      isReady =
          true; // set ready flag when completed to discover the available services
    });
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

  discoverServices() async {
    // if (widget.device == null) {
    //   _Pop();
    //   return;
    // }

    print('discoverServices: Device Mac Address: ${widget.device.id}');
    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      print('- service: ${service.uuid.toString()}');
      service.characteristics.forEach((characteristic) async {
        print('-- characteristic: ${characteristic.uuid.toString()}');
        print(
            '   properties: read=${characteristic.properties.read}, write=${characteristic.properties.write}, notify=${characteristic.properties.notify}');
        if (characteristic.uuid ==
            new Guid("00002a06-0000-1000-8000-00805f9b34fb")) {
          _btCharCallItag = characteristic;
          print('found char. uuid for writing iTag alarm on/off');
        }

        // set notify iTag button pressing
        if (characteristic.uuid ==
            new Guid("0000ffe1-0000-1000-8000-00805f9b34fb")) {
          //                    0000ffe1-0000-1000-8000-00805f9b34fb
          print('match iTag button char. uuid');
          _btCharNotifyPressItagBt = characteristic;
          notifyStreamPressingItag = _btCharNotifyPressItagBt!.value.listen((value) { //ok
            print('callback0 of _btCharCallItag value=${value}, value type=${value.runtimeType}');

            if (value.isNotEmpty) { // if the buffer has any value, it is occurred from pressing iTag
              // start vibrate (+ start timer for control vibrate)
              flagStartVibrate = !flagStartVibrate;
              print('flagStartVibrate = $flagStartVibrate');
              if (flagStartVibrate) {
                timerVibrate = Timer.periodic(Duration(seconds: 3), (Timer t) => vibrateAction());
              } else {
                vibrateStatus = false;
                timerVibrate?.cancel();
              }
            }

          });

          print('start setting notify to true');
          // await characteristic.setNotifyValue(true);
          await _btCharNotifyPressItagBt!.setNotifyValue(true); // ?? why setNotifyValue has not finished ?
          print('set notify successfully');


          // _btCharNotifyPressItagBt!.value.listen((value) { //ng1
          //   print('callback1 of _btCharCallItag value=${value}');
          // });

          // _streamItagPressStatus = characteristic.value; //ng2

          // _btCharNotifyPressItagBt!.value.listen((value) { // ng3
          //   print('callback3 of _btCharCallItag value=${value}');
          //   readValues[characteristic.uuid] = value;
          // });

          // characteristic.value.listen((value) { //ng4
          //   print('callback4 of _btCharCallItag value=${value}');
          // });

        }
        characteristic.descriptors.forEach((descriptor) {
          print('--- descriptor: ${descriptor.uuid.toString()}');
        });
      });
    });

    // if (!isReady) {
    //   _Pop();
    // }
  }

  @override
  Widget build(BuildContext context) {
    String _strDevice = 'Welcome to sensor page';
    _strDevice = _strDevice + '\nMac Address: ${widget.device.id}';
    _strDevice = _strDevice + '\nDevice Name: ${widget.device.name}';


    // if (_btCharNotifyPressItagBt != null) {
    //   _btCharNotifyPressItagBt!.value.listen((value) {
    //     print('callback111 of _btCharCallItag value=${value}');
    //   });
    // }


    return Scaffold(
        appBar: AppBar(
          title: Text('sensor page'),
        ),
        body: isReady
            ? Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(_strDevice),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (_btCharCallItag != null) {
                            _isCallItag =
                                !_isCallItag; // toggle calling iTag status
                            int _sendVal = _isCallItag ? 1 : 0;
                            _btCharCallItag!.write([_sendVal],
                                withoutResponse:
                                    true); // need to add bracket to _setVal bc. .write want List<int>
                            // if (_btCharNotifyPressItagBt != null) {
                            //   print('callback331');
                            //   _btCharNotifyPressItagBt!.value.listen((value) {
                            //     print(
                            //         'callback332 of _btCharCallItag value=${value}');
                            //   });
                            //   print('callback333');
                            // } else {
                            //   print('callback334');
                            // }
                          }
                        });
                      },
                      child: (_isCallItag)
                          ? Text('Calling iTag',
                              style: TextStyle(color: Colors.white))
                          : Text('Call iTag',
                              style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        // onPrimary: Colors.green, // สี bg ของปุ่มจังหวะที่กดลง
                        // primary: Colors.yellow, // สี bg ของปุ่มจังหวะปกติ (ตอนที่ยังไม่ได้กดลง)
                        primary: (_isCallItag) // สี bg ของปุ่ม แบบมีเงื่อนไข
                            ? Colors
                                .green // elevated bt bg color when call iTag
                            : null, // use default color
                      ),
                    )
                  ],
                ),
              )
            : Container(
                child: Center(
                  child:
                      Text('Waiting ...', style: TextStyle(color: Colors.red)),
                ),
              ));
  }
}
