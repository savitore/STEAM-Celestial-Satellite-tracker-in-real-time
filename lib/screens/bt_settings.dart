import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';

class BTSettings extends StatefulWidget {
  const BTSettings({super.key});

  @override
  State<BTSettings> createState() => _BTSettingsState();
}

class _BTSettingsState extends State<BTSettings> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothConnection? _connection;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Request Bluetooth permission
    FlutterBluetoothSerial.instance.requestEnable().then((value) {
      setState(() {
        _bluetoothState = value! ? BluetoothState.STATE_ON : BluetoothState.STATE_OFF;
      });
    });

  }

  void _startDiscovery() {
    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      setState(() {
        BluetoothDevice device = result.device;
        _devicesList.add(device);
      });
    });
  }

  void _cancelDiscovery() {
    FlutterBluetoothSerial.instance.cancelDiscovery();
  }

  void _connectToDevice(BluetoothDevice device) async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
    }

    // Establish connection
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      print('Connected to the device!');
    } catch (e) {
      print('Connection failed: $e');
    }

  }

  Future<void> _disconnectFromDevice() async {
    if (_connection != null && _connection!.isConnected) {
      await _connection!.close();
      print('Disconnected from the device!');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.primaryColor,
        title: Text('Bluetooth Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              'Bluetooth State: $_bluetoothState',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _startDiscovery,
              child: Text('Start Discovery'),
            ),
            ElevatedButton(
              onPressed: _cancelDiscovery,
              child: Text('Cancel Discovery'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Available Devices:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: ListView.builder(
                itemCount: _devicesList.length,
                itemBuilder: (context, index) {
                  BluetoothDevice device = _devicesList[index];
                  return ListTile(
                    title: Text(device.name!),
                    subtitle: Text(device.address),
                    onTap: () => _connectToDevice(device),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _disconnectFromDevice,
              child: Text('Disconnect'),
            ),
          ],
        ),
      ),
    );
  }
}
