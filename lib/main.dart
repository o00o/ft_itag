import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart'; // use ble
import 'package:ft_itag/pages/sensor_page.dart';

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

class FindItagPage extends StatelessWidget {
  const FindItagPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Device List'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBlue.instance.scanResults,
                initialData: [],
                builder: (context, snapshot) {
                  return Column(
                      children: snapshot.data!
                          .map(
                              // เอาข้อมูล scanResult มาทำเป็น List ของ Widget ScanResultItem
                              // แสดงค่า bt device id + name ที่scan เจอ + connect button
                              (r) => ScanResultItem(
                                    btScanResult: r,
                                    // onTap: () { //// write onTap 1st style --> ok
                                    //   print('go to next page');
                                    //   Navigator.of(context).push(
                                    //       MaterialPageRoute(builder: (context) {
                                    //     r.device.connect();
                                    //     return SensorPage();
                                    //   }));
                                    // },

                                    // //// write onTap 2nd style --> ok
                                    // onTap: () => Navigator.of(context).push(
                                    //     MaterialPageRoute(builder: (context) {
                                    //   r.device.connect();
                                    //   return SensorPage(device: r.device);
                                    // })),

                                    // onTap: () {
                                    //   //// write onTap 3.1nd method
                                    //   // (disconnect device when press back from SensorPage) --> ok
                                    //   print('go to next page');
                                    //   Navigator.of(context).push(
                                    //       MaterialPageRoute(builder: (context) {
                                    //     r.device.connect();
                                    //     return SensorPage(device: r.device);
                                    //   })).then((context) => r.device.disconnect());
                                    // },

                                    onTap: () {
                                      //// write onTap 3.2nd method
                                      // (disconnect device when press back from SensorPage) --> ok
                                      print('go to next page');
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        r.device.connect();
                                        return SensorPage(device: r.device);
                                      })).then((context) {
                                        r.device.disconnect();
                                      });
                                    },
                                  ))
                          .toList());
                },
              )
            ],
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: FlutterBlue.instance.isScanning,
          // stream ค่าสถานะการ scan ble ว่ากำลัว scan อยู่รึเปล่า
          initialData: false,
          builder: (context, snapshot) {
            if (snapshot.data!) {
              // bt is scanning
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () {
                  // ถ้าระหว่างที่ bt กำลัง scan เรากด stop การ scan ได้
                  FlutterBlue.instance.stopScan();
                },
                backgroundColor: Colors.red,
              );
            } else {
              // bt is NOT scanning
              return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  // ถ้าไม่ใส่ timeout ในการ scan มันจะ scan ไม่หยุดเลย, ไม่อย่างนั้นต้องสั่ง .stopScan
                  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
                },
              );
            }
          },
        ));
  }
}

class ScanResultItem extends StatelessWidget {
  const ScanResultItem({Key? key, required this.btScanResult, this.onTap})
      : super(key: key);

  final ScanResult btScanResult;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: ListTile(
        leading: Text('${btScanResult.rssi}'),
        title: Text('Mac Address: ${btScanResult.device.id}'),
        subtitle: Text('Device Name:${btScanResult.device.name}'),
        trailing: ElevatedButton(
          child: Text('Connect'),
          onPressed:
              // ถ้า btScanResult บอกว่าอุปกรณ์นี้ connect ไม่ได้
              // จะdisable ปุ่มไม่ให้กดได้ โดย setค่า onPressed เป็น null
              (btScanResult.advertisementData.connectable) ? onTap : null,
        ),
        tileColor: Colors.grey.shade200,
      ),
    );
  }
}
