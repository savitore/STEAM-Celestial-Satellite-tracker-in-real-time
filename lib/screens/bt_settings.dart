import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/colors.dart';
import 'package:steam_celestial_satellite_tracker_in_real_time/utils/snackbar.dart';

class BTSettings extends StatefulWidget {
  const BTSettings({super.key});

  @override
  State<BTSettings> createState() => _BTSettingsState();
}

class _BTSettingsState extends State<BTSettings> {

  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> _devicesList = [];
  BluetoothConnection? _connection;
  // To track whether the device is still connected to Bluetooth
  bool get isConnected => _connection != null && _connection!.isConnected;
  BluetoothDevice? _device;
  int? _deviceState;
  bool isDisconnecting = false,_connected=false;
  bool _isButtonUnavailable = false;
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  @override
  void initState() {
    super.initState();
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _deviceState=0;

    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    if (isConnected) {
      isDisconnecting = true;
      _connection?.dispose();
      _connection = null;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<bool> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // void _startDiscovery() {
  //   FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
  //     setState(() {
  //       BluetoothDevice device = result.device;
  //       _devicesList.add(device);
  //     });
  //   });
  // }
  //
  // void _cancelDiscovery() {
  //   FlutterBluetoothSerial.instance.cancelDiscovery();
  // }

  // void _connectToDevice(BluetoothDevice device) async {
  //   if (_connection != null && _connection!.isConnected) {
  //     await _connection!.close();
  //   }
  //
  //   // Establish connection
  //   try {
  //     _connection = await BluetoothConnection.toAddress(device.address);
  //     print('Connected to the device!');
  //   } catch (e) {
  //     print('Connection failed: $e');
  //   }
  //
  // }

  // Future<void> _disconnectFromDevice() async {
  //   if (_connection != null && _connection!.isConnected) {
  //     await _connection!.close();
  //     print('Disconnected from the device!');
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: ThemeColors.primaryColor,
        title: const Text('Bluetooth Connection'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton.icon(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            label: const Text(
              "Refresh",
              style: TextStyle(
                color: Colors.white,fontSize: 20,fontWeight: FontWeight.w700,
              ),
            ),
            onPressed: () async {
              await getPairedDevices().then((_) {
                showSnackbar(context,'Device list refreshed');
              });
            },
          ),
          Visibility(
            visible: _isButtonUnavailable &&
                _bluetoothState == BluetoothState.STATE_ON,
            child: const LinearProgressIndicator(
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Expanded(
                  child: Text(
                    'Enable Bluetooth',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: _bluetoothState.isEnabled,
                  onChanged: (bool value) {
                    future() async {
                      if (value) {
                        await FlutterBluetoothSerial.instance
                            .requestEnable();
                      } else {
                        await FlutterBluetoothSerial.instance
                            .requestDisable();
                      }

                      await getPairedDevices();
                      _isButtonUnavailable = false;

                      if (_connected) {
                        _disconnect();
                      }
                    }

                    future().then((_) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
          ),
          Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      "PAIRED DEVICES",
                      style: TextStyle(fontSize: 24, color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Device:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        DropdownButton(
                          items: _getDeviceItems(),
                          onChanged: (value) =>
                              setState(() => _device = value),
                          value: _devicesList.isNotEmpty ? _device : null,
                        ),
                        ElevatedButton(
                          onPressed: _isButtonUnavailable
                              ? null
                              : _connected ? _disconnect : _connect,
                          child:
                          Text(_connected ? 'Disconnect' : 'Connect'),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 20,),
                ],
              ),
              Container(color: Colors.blue),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      child: const Text("Bluetooth Settings"),
                      onPressed: () {
                        FlutterBluetoothSerial.instance.openSettings();
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

// Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      showSnackbar(context,'No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device?.address)
            .then((connection) {
          print('Connected to the device');
          _connection = connection;
          setState(() {
            _connected = true;
          });

          _connection?.input?.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
        showSnackbar(context,'Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await _connection?.close();
    showSnackbar(context,'Device disconnected');
    if (!_connection!.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

}
