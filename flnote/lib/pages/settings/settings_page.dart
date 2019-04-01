import 'dart:async';

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';

import 'package:niknote/scoped_models/app_model.dart';
import 'package:niknote/widgets/ui_elements/loading_modal.dart';
import 'package:niknote/widgets/helpers/confirm_dialog.dart';

import 'package:flutter_blue/flutter_blue.dart';

class SettingsPage extends StatefulWidget {
  final AppModel model;

  SettingsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {



  List<int> _settings = [30,7777,5];


  FlutterBlue _flutterBlue = FlutterBlue.instance;

  /// Scanning
  StreamSubscription _scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription _stateSubscription;
  BluetoothState state = BluetoothState.unknown;

  /// Device
  BluetoothDevice device;

  bool get isConnected => (device != null);
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();

  BluetoothCharacteristic characteristic;

  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  @override
  void initState() {
    super.initState();
    // handle _stateSubscription and state of _flutterBlue
    _flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });
    // Subscribe to state changes
    _stateSubscription = _flutterBlue.onStateChanged().listen((s) {
      setState(() {
        state = s;
      });
    });
  }

  @override
  void dispose() {
    // dispose of subscriptions..

    // close stateSubsr
    _stateSubscription?.cancel();
    _stateSubscription = null;

    // close scanSubscr
    _scanSubscription?.cancel();
    _scanSubscription = null;

    // close deviceConnectionSubscr
    deviceConnection?.cancel();
    deviceConnection = null;

    super.dispose();
  }

  // scanning for devices
  void _startScan() {
    print('start scan');
    // handle scanning for devices and save them. Also call setState()
    // set isScanning on true and call setState()
    // use _stopScan when done scanning

    _scanSubscription = _flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
        .listen((scanResult) {

    //  print('localName: ${scanResult.advertisementData.localName}');
    //  print(
    //      'manufacturerData: ${scanResult.advertisementData.manufacturerData}');
    //  print('serviceData: ${scanResult.advertisementData.serviceData}');

      setState(() {
        scanResults[scanResult.device.id] = scanResult;
      });
    }, onDone: _stopScan);

    setState(() {
      isScanning = true;
    });
  }

  // stop Scanning
  void _stopScan() {
    // dispose of _scanSubscription and set isScanning on false; call setState
    _scanSubscription?.cancel();
    _scanSubscription = null;
    setState(() {
      isScanning = false;
    });
  }

  // Connect to device
  void _connectToDevice(BluetoothDevice dev) {
    device = dev;
    // Connect to device
    deviceConnection = _flutterBlue
        .connect(device, timeout: const Duration(seconds: 5))
        .listen(
          null,
          onDone: _disconnectFromDevice,
        );

    // Update the connection state immediately
    device.state.then((s) {
      setState(() {
        deviceState = s;
      });
    });

    // Subscribe to connection changes
    deviceStateSubscription = device.onStateChanged().listen((s) {
      setState(() {
        deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        device.discoverServices().then((s) {
          setState(() {
            services = s;
            characteristic = services[2].characteristics[0];
          });
        });
      }
    });
  }

  // Disconnect from current device
  void _disconnectFromDevice() {
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    setState(() {
      device = null;
    });
    //..
  }

  // Write characteristic method
  _writeCharacteristic(BluetoothCharacteristic c,List<int> values) async {
    if(!isConnected) {
      return;
    }
    await device.writeCharacteristic(c, values,
        type: CharacteristicWriteType.withResponse);
    setState(() {});
  }

  void updateSettings(List newSettings) {
    setState(() {
      this._settings[0] = newSettings[0];
      this._settings[1] = newSettings[1];
      this._settings[2] = newSettings[2];
    });
  }

  Widget _createHomeWidget() {
    if (state != BluetoothState.on) {
      return new Center(
        child: Text('Please turn on Bluetooth'),
      );
    }
    if (isConnected) {
      // show information about connected device
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: <Widget>[
            Text('Device connected!'),
            SizedBox(height: 50),
            new RaisedButton(
              color: Theme.of(context).accentColor,
              onPressed: () {
                _disconnectFromDevice();
              },
              child: new Text('Disconnect', style: TextStyle(color: Colors.white)),
            )
          ],
        )

      );
    } else {
      // scan for devices
      if (isScanning) {
        // If scanning show stop button
        return new Center(
          child: new ListView(
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    _stopScan();
                  },
                  child: new Icon(Icons.stop)
              ),

            ],
          )
        );
      } else {
        // If not scanning show search button
        print("Showing searh button");
        return new Center(
            child: new ListView(
              children: <Widget>[
                RaisedButton(
                    onPressed: () {
                      _startScan();
                    },
                    child: new Icon(Icons.search)
                ),

                new Column(
                  children: _createListFromScanResults(),
                ),

              ],
            )
        );

      }
    }
  }

  List<Widget> _createListFromScanResults() {
  //  print(scanResults.isEmpty);
    List<Widget> ret = new List<Widget>();
    Widget w;

    scanResults.forEach((d,r) {
      Widget text;
      int i = 0;
      if (r.advertisementData.localName != null && r.advertisementData.localName != "" ) {
        if (r.device.id.toString() == "F7:A4:5E:88:83:53") {
          text = new Text(r.advertisementData.localName);
          i = 1;
        }
       // text = new Text(r.advertisementData.localName);
      } else {
      //  text = new Text(r.device.id.toString());
      }
      if (i == 1) {
        w = new RaisedButton(onPressed: () {
          _connectToDevice(r.device);
        },
          child: text,);

        ret.add(w);
      }

     // print(r.device.id.toString());
    });
    return ret;
  }

  void startVibrationBurst() {
    print("Starting vibration burst");
    _writeCharacteristic(characteristic, [0xffffffffff]);
     new Timer(const Duration(milliseconds: 900), () {
       print("Stopping vibration");
       _writeCharacteristic(characteristic,[0x0000000000]);
    });
  }

  Widget _ModesWidget() {
    return Column(children: <Widget>[
      new RaisedButton(
        child: new Text("Start vibration"),
        onPressed: (){
          startVibrationBurst();
        },
      )
      // new Text(data)
    ],);
  }

  Widget _createTabBarView() {
    return new TabBarView(
      children: <Widget>[
     //   new HomeWidget(),
        _createHomeWidget(),
        // new ModesWidget(
        //   startVibFunction: _writeCharacteristic,
        //   stopVibFunction: _writeCharacteristic,
        //   characteristic: characteristic,
        //   startPara: [0xffffffffff],
        //   stopPara: [0x0000000000],
        //   settings: this._settings,
        // ),
        // new SettingsWidget(
        //     updateSettings: updateSettings,
        //     initWaterTime: this._settings[0],
        //     initWalkTime: this._settings[1],
        //     initWalkSteps: this._settings[2]
        // ),
     //   new SettingsWidget(updateSettings: updateSettings, initWaterTime: this._settings.elementAt(0), initWalkTime: this._settings.elementAt(1)),
      ],
    );
  }





  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppModel>(
      builder: (BuildContext context, Widget child, AppModel model) {
        // return _buildPageContent(model);
         return new DefaultTabController(
      length: 3,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Vibration Reminder"),
          bottom: new TabBar(
            tabs: <Widget>[
              new Tab(icon: new Icon(Icons.home)),
              new Tab(text: "Modes"),
              new Tab(icon: new Icon(Icons.settings)),
            ],
          ),
        ),
        body: _createTabBarView(),
      ),
    );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, AppModel model) {
    return AppBar(
      title: Text('Settings'),
      backgroundColor: Colors.blue,
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.lock),
          onPressed: () async {
            bool confirm = await ConfirmDialog.show(context);

            if (confirm) {
              Navigator.pop(context);

              model.logout();
            }
          },
        ),
      ],
    );
  }

  Widget _buildPageContent(AppModel model) {
    return model.isLoading
        ? LoadingModal()
        : Scaffold(
            appBar: _buildAppBar(context, model),
            body: ListView(
              children: <Widget>[
                SwitchListTile(
                  activeColor: Colors.blue,
                  value: model.settings.isShortcutsEnabled,
                  onChanged: (value) {
                    model.toggleIsShortcutEnabled();
                  },
                  title: Text('Enable shortcuts'),
                ),
                SwitchListTile(
                  activeColor: Colors.blue,
                  value: model.settings.isDarkThemeUsed,
                  onChanged: (value) {
                    model.toggleIsDarkThemeUsed();
                  },
                  title: Text('Use dark theme'),
                )
              ],
            ),
          );
  }
}
