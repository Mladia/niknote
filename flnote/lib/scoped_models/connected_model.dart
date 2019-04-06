import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:http/http.dart' as http;
import 'package:niknote/.env.example.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:niknote/models/filter.dart';
import 'package:niknote/models/Todo.dart';

mixin CoreModel on Model {
  List<Todo> _todos = [];
  Todo _todo;
  bool _isLoading = false;
  Filter _filter = Filter.Current;
}

mixin TodosModel on CoreModel {
  List<Todo> get todos {
    switch (_filter) {
      case Filter.All:
        return List.from(_todos);

      case Filter.Done:
        return List.from(_todos.where((todo) => todo.isDone));

      case Filter.Current:
        return List.from(_todos.where((todo) {
          var todo2 = todo;
                    return (!todo2.isDone && !todo.snoozed);
        }));
      case Filter.Snoozed:
        return List.from(_todos.where((todo) {
          var todo2 = todo;
                    return (!todo2.isDone && todo.snoozed);
        }));

    }

    return List.from(_todos);
  }

  Filter get filter {
    return _filter;
  }

  bool get isLoading {
    return _isLoading;
  }

  Todo get currentTodo {
    return _todo;
  }

  void applyFilter(Filter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setCurrentTodo(Todo todo) {
    _todo = todo;
  }




  Future fetchTodos() async {
    print("Fetching todos");
    _isLoading = true;
    notifyListeners();

    try {
      final String url = Configure.ServerUrl;
      print("from url:" + url);
      final String body = "cmd=get_notes";
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: body
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        print("not 200 or 201 status code");
        notifyListeners();
        return;
      }


    final List <dynamic> todoListData = json.decode(response.body);
      if (todoListData == null) {
        print("Fetched notes are null");
        _isLoading = false;
        notifyListeners();
        return;
      }

    _todos = [];
    todoListData.forEach( (dynamic todoData) {
        if (todoData == null) {
          // print("null note");
          return;
        }
        DateTime dateTodo;
        try {
          if (todoData['snoozed'] == true ) {
            dateTodo = DateTime.parse(todoData['snoozed_date'] + " " + todoData['snoozed_time']);
          }
        print(dateTodo);
        } catch (error) {
          print("Parsing time error in fetch todos:" + error);
        }
        final Todo todo = Todo (
          id: todoData['id'],
          title: todoData['title'],
          content: todoData['text'],
          snoozed: todoData['snoozed'],
          snoozedDate: dateTodo,
          isDone: todoData['done'],
          image: todoData['image'],
          tags: new List<String>.from( todoData['tags'])
        );

        if (todo.snoozed) {
          print(todo.toJson());
        }
        _todos.add(todo);
      });
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      print("Error fetching");
      _isLoading = false;
      notifyListeners();
    }
  }

Future<bool> _pushNotes() async {
  // return true;
  print("Pushing notes");
  List jsonList = List();
  int currentId = 0;
  var it = _todos.iterator;
  while (it.moveNext()) {
    while (it.current.id !=currentId) {
      jsonList.add("null");
      currentId++;
    }

    jsonList.add(it.current.toJson());
    if (it.current.snoozed) {
      print("Adding " + it.current.toJson());
    }
    currentId++;
  }
  final String notes = jsonList.toString();
  final String url = Configure.ServerUrl;
  print("from url:" + url);

  final String data = '{ "cmd" : "push_notes", "notes" : ' + notes + '}';

  try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: data 
      );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("not 200 or 201 status code");
      await fetchTodos();
      return false;
    }

    try {
      final Map <String, dynamic> decoded =  json.decode(response.body); 
      final String success = decoded['success'];
      print("3Returning success: " + success);
      return success == "true";
    } catch (e) {
      print("Problem decoding result");
      await fetchTodos();
      print("sorry boy");
      return false;
    }

  } catch (e) {
    print("Problem sending");
    await fetchTodos();
    return false;
  }
}


  Future<bool> createTodo(
      String title, String content, bool isDone, DateTime snoozedDate) async {
    _isLoading = true;
    notifyListeners();
    print("Creating todo");

    int newId = _todos.last.id + 1;
    //PRAY TO GOD NO DUPLICATES
    Todo todo = Todo(
      id: newId,
      title: title,
      content: content,
      isDone: isDone,
      snoozed: snoozedDate == null ? false : true,
      snoozedDate: snoozedDate,
    );
    _todos.add(todo);

    final bool success  = await _pushNotes();

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> updateTodo(
      String newTitle, 
      String newContent,
      DateTime snoozedDate
      ) async {

    print("Updating todo");
    _isLoading = true;
    notifyListeners();


    Todo todo = Todo(
      id: currentTodo.id,
      title: newTitle,
      content: newContent,
      image: currentTodo.image,
      snoozed: snoozedDate == null ? false : true,
      snoozedDate: snoozedDate,
      tags: currentTodo.tags,
      isDone: currentTodo.isDone
    );

      int todoIndex = _todos.indexWhere((t) => t.id == currentTodo.id);
      _todos[todoIndex] = todo;

     final bool success = await _pushNotes();
          _isLoading = false;
          notifyListeners();
          return success;
}
                  
Future<bool> removeTodo(int id) async {
  _isLoading = true;
  notifyListeners();

  // Todo todo = _todos.firstWhere((t) => t.id == id);
  int todoIndex = _todos.indexWhere((t) => t.id == id);
  _todos.removeAt(todoIndex);
  final bool success = await _pushNotes();
  _isLoading = false;
  notifyListeners();
  return success;
}

Future<bool> toggleDone(int id) async {

  print("Toggle done");
  _isLoading = true;
  notifyListeners();

  Todo todo = _todos.firstWhere((t) => t.id == id);

    todo = Todo(
      id: todo.id,
      title: todo.title,
      content: todo.content,
      isDone: !todo.isDone,
      image: todo.image,
      snoozed: todo.snoozed,
      snoozedDate: todo.snoozedDate,
      tags: todo.tags,
    );
    int todoIndex = _todos.indexWhere((t) => t.id == id);
    _todos[todoIndex] = todo;


     final bool success = await _pushNotes();
      _isLoading = false;
      notifyListeners();
      return success;
      
}

Future<bool> snoozeNote(int id,  DateTime toSnoozeDate) async {
  _isLoading = true;
  notifyListeners();
  Todo todo = _todos.firstWhere((t) => t.id == id);

  if (toSnoozeDate == null) {
    DateTime now = DateTime.now();
    int newMinute = now.minute + 3;
    String formattedNow = "${now.year}.${now.month}.${now.day} at ${now.hour}:$newMinute";
    toSnoozeDate = DateTime.parse(formattedNow);
  }
  print("Snooze note for " + toSnoozeDate.toString());
  todo = Todo(
    id: todo.id,
    title: todo.title,
    content: todo.content,
    isDone: todo.isDone,
    image: todo.image,
    snoozed: true,
    snoozedDate: toSnoozeDate,
    tags: todo.tags,
  );
  int todoIndex = _todos.indexWhere((t) => t.id == id);
  
  _todos[todoIndex] = todo;
  print(todo.toJson());
  final bool success = await _pushNotes();
  _isLoading = false;
  notifyListeners();
  return success;
}

Future<bool> unsnoozeNote(int id) async {
  print("Unsnoozing note");
  _isLoading = true;
  notifyListeners();
  Todo todo = _todos.firstWhere((t) => t.id == id);
  todo = Todo(
    id: todo.id,
    title: todo.title,
    content: todo.content,
    isDone: todo.isDone,
    image: todo.image,
    snoozed: false,
    snoozedDate: null,
    tags: todo.tags,
  );
  int todoIndex = _todos.indexWhere((t) => t.id == id);
  
  _todos[todoIndex] = todo;
  print(todo.toJson());
  final bool success = await _pushNotes();
  _isLoading = false;
  notifyListeners();
  return success;

}

List<Todo> snoozedNotes(){
  List<Todo> snoozed = List();
  Iterator todosIt = _todos.iterator;

  while(todosIt.moveNext()) {
      if (todosIt.current.snoozed) {
        snoozed.add(todosIt.current);
      }
  }

  return snoozed;
}

}

mixin BluetoothModel on CoreModel {

  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice device; 
  BluetoothCharacteristic characteristic;

  /// Scanning
  StreamSubscription scanSubscription;
  Map<DeviceIdentifier, ScanResult> scanResults = new Map();
  bool isScanning = false;

  /// State
  StreamSubscription stateSubscription;
  BluetoothState state = BluetoothState.unknown;


  bool get isConnected => (device != null);
  bool connectedSimulated = false;
  StreamSubscription deviceConnection;
  StreamSubscription deviceStateSubscription;
  List<BluetoothService> services = new List();


  Map<Guid, StreamSubscription> valueChangedSubscriptions = {};
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;


  void _dispose() {
    print("dispose");
    // dispose of subscriptions..

    // close stateSubsr
    stateSubscription?.cancel();
    stateSubscription = null;

    // close scanSubscr
    scanSubscription?.cancel();
    scanSubscription = null;

    // close deviceConnectionSubscr
    deviceConnection?.cancel();
    deviceConnection = null;


  }
  
  void startScan() {
    print('start scan');

    scanSubscription = flutterBlue
        .scan(
      timeout: const Duration(seconds: 5),
    )
    .listen((scanResult) {
      print('localName: ${scanResult.advertisementData.localName}');
        scanResults[scanResult.device.id] = scanResult;
        notifyListeners();
    }, onDone: stopScan);

      isScanning = true;
  }

  void stopScan() {
    scanSubscription?.cancel();
    scanSubscription = null;
      isScanning = false;
      notifyListeners();
  }
  // Write characteristic method
  _writeCharacteristic(BluetoothCharacteristic c,List<int> values) async {
    if(device == null) {
      return;
    }
    await device.writeCharacteristic(c, values,
        type: CharacteristicWriteType.withResponse);
  }



  // Connect to device
  void connectToDevice(BluetoothDevice dev) {
    _isLoading = true;
    notifyListeners();
    
    print("connect to device");
    device = dev;
    // Connect to device
    deviceConnection = flutterBlue
        .connect(device, timeout: const Duration(seconds: 5))
        .listen(
          null,
          onDone: disconnectFromDevice,
        );

    // Update the connection state immediately
    device.state.then((s) {
        deviceState = s;
    });

    // Subscribe to connection changes
    deviceStateSubscription = device.onStateChanged().listen((s) {
        deviceState = s;
      if (s == BluetoothDeviceState.connected) {
        device.discoverServices().then((s) {
            services = s;
            characteristic = services[2].characteristics[0];
            _isLoading = false;
            notifyListeners();
            vibrationBurst();
        });
      } else {
        print("connected, but not connected");

      }
    });

    // _isLoading = false;
    // notifyListeners();

  }

  // Disconnect from current device
  void disconnectFromDevice() {
    print("disconnect from device");
    valueChangedSubscriptions.forEach((uuid, sub) => sub.cancel());
    valueChangedSubscriptions.clear();
    deviceStateSubscription?.cancel();
    deviceStateSubscription = null;
    deviceConnection?.cancel();
    deviceConnection = null;
    device = null;

    _isLoading = false;
    notifyListeners();

  }

  bool vibrationBurst() {
    if (device == null) {
      print("Device not connected");
      return false;
    }
    
    _writeCharacteristic(characteristic, [ 0xf0, 0xf0, 0xf0, 0x30]);

    new Timer(const Duration(milliseconds: 1500), () {
    _writeCharacteristic(characteristic, [ 0x0 , 0x0 , 0x0, 0x0]);
      // _writeCharacteristic(characteristic,[0x00, 0x00, 0x00, 0x00]);
    });

    return true;
  }

  void vibrationPattern() {

    if (device == null) {
      print("Device not connected");
      return;
    }

    print("Starting vibration pattern");
    int i = 0xf;
    int limit = 0xbb;
    int step = 0x1;
    // for (; i < limit; i+=step) {
    //   _writeCharacteristic(characteristic, [ i, 0x3, i, 0x3]);

    //   new Timer(const Duration(milliseconds: 300), () {
    //   _writeCharacteristic(characteristic, [ 0x3 , i , 0x3, i]);
    //   });
    // }

    _writeCharacteristic(characteristic, [ 0xf0, 0x33, 0xf0, 0x33]);

    new Timer(const Duration(milliseconds: 700), () {
      print("second vibr");
      _writeCharacteristic(characteristic,[0x30, 0xf0, 0x30, 0xf0]);
      new Timer(const Duration(milliseconds: 500), () {
        print('third');
        _writeCharacteristic(characteristic, [ 0xf0 , 0x30 , 0x33, 0xff]);
        new Timer(const Duration(milliseconds: 1000), () {
          print("stopping all");
          _writeCharacteristic(characteristic,[0x00, 0x00, 0x00, 0x00]);
        });
      });
    });

      //stop all
  }
}

mixin UserModel on CoreModel {
}


mixin SettingsModel on CoreModel {
  void loadSettings() async {
    return;
  }

  bool _loadIsShortcutsEnabled(SharedPreferences prefs) {
    return false;
  }

  bool _loadIsDarkThemeUsed(SharedPreferences prefs) {
    return false;
  }

  Future toggleIsShortcutEnabled() async {
    return;
  }

  Future toggleIsDarkThemeUsed() async {
    return;
  }
}
