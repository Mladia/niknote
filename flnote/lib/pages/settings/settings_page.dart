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
  // SettingsPage();

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState(model);
  }
}

class _SettingsPageState extends State<SettingsPage> {

  final AppModel model;
  _SettingsPageState(this.model);



  // List<int> _settings = [30,7777,5];
  // List<int> _settings = [7777,7777,7777];
  // List<int> _settings = [9999 , 9999, 9999];

  @override
  void initState() {
    super.initState();

    // handle _stateSubscription and state of _flutterBlue
    model.flutterBlue.state.then((s) {
      setState(() {
        model.state = s;
      });
    });
    // Subscribe to state changes
    model.stateSubscription = model.flutterBlue.onStateChanged().listen((s) {
      setState(() {
        model.state = s;
      });
    });
  }


  @override
  void dispose() {
    print("dispose");
    // model.dispose();

    super.dispose();
  }



  // void updateSettings(List newSettings) {
  //   setState(() {
  //     this._settings[0] = newSettings[0];
  //     this._settings[1] = newSettings[1];
  //     this._settings[2] = newSettings[2];
  //   });
  // }

  Widget _createHomeWidget() {
    if (model.state != BluetoothState.on) {
      return new Center(
        child: Text('Please turn on Bluetooth'),
      );
    }
    if (model.isConnected) {
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
                model.disconnectFromDevice();
              },
              child: new Text('Disconnect', style: TextStyle(color: Colors.white)),
            ),
            _modesWidget()
          ],
        )

      );
    } else {
      // scan for devices
      if (model.isScanning) {
        // If scanning show stop button
        return new Center(
          child: new ListView(
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    model.stopScan();
                  },
                  child: new Icon(Icons.stop)
              ),

            ],
          )
        );
      } else {
        // If not scanning show search button
        return new Center(
            child: new ListView(
              children: <Widget>[
                RaisedButton(
                    onPressed: () {
                      model.startScan();
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

    model.scanResults.forEach((d,r) {
      Widget text;
      int i = 0;
      if (r.advertisementData.localName != null && r.advertisementData.localName != "" ) {
        //TODO: show only this device?
        // if (r.device.id.toString() == "F7:A4:5E:88:83:53") {
        //   text = new Text(r.advertisementData.localName);
        //   i = 1;
        // }
        text = new Text(r.advertisementData.localName);
      } else {
        // text = new Text(r.device.id.toString());
      }
      if (i == 1) {
        w = new RaisedButton(onPressed: () {
          model.connectToDevice(r.device);
        },
          child: text,);

        ret.add(w);
      }

      print(r.device.id.toString());
    });
    return ret;
  }



  Widget _modesWidget() {
    return Column(children: <Widget>[
      new RaisedButton(
        child: new Text("Start vibration"),
        onPressed: () async {
          
          if (model.device != null) {
            print("device not null in settings");
          } else {
            print("device is null in settings");
          }
          model.vibrationBurst();
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
        // _modesWidget()
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
          title: new Text("Connect to device..."),
          bottom: new TabBar(
            tabs: <Widget>[
              new Tab(icon: new Icon(Icons.home)),
              // new Tab(text: "Modes"),
              // new Tab(icon: new Icon(Icons.settings)),
            ],
          ),
        ),
        body: _createTabBarView(),
      ),
    );
      },
    );
  }

}
