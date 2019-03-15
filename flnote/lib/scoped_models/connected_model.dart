import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:niknote/.env.example.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';

import 'package:niknote/models/user.dart';
import 'package:niknote/models/filter.dart';
import 'package:niknote/models/Todo.dart';
import 'package:niknote/models/settings.dart';

mixin CoreModel on Model {
  List<Todo> _todos = [];
  Todo _todo;
  bool _isLoading = false;
  Filter _filter = Filter.All;
  User _user = User( id: "0", email: "s@gmail.com", token: "s");
}

mixin TodosModel on CoreModel {
  List<Todo> get todos {
    switch (_filter) {
      case Filter.All:
        return List.from(_todos);

      case Filter.Done:
        return List.from(_todos.where((todo) => todo.isDone));

      case Filter.NotDone:
        return List.from(_todos.where((todo) => !todo.isDone));
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
      String url = "http://192.168.2.38/server.php";
      String body = "cmd=get_notes";
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

    todoListData.forEach( (dynamic todoData) {
        if (todoData == null) {
          print("null note");
          return;
        }
      
        final Todo todo = Todo (
          id: todoData['id'],
          title: todoData['title'],
          content: todoData['text'],
          snoozed: todoData['snoozed'],
          isDone: todoData["done"],
          snoozedDate: todoData['snoozedDate'],
          snoozedTime: todoData['snoozedTime'],
          image: todoData['image'],
          tags: new List<String>.from( todoData['tags'])
        );

        print(todo.toString());
        _todos.add(todo);
      });
      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<bool> createTodo(
      String title, String content, bool isDone) async {
    _isLoading = true;
    notifyListeners();
    print("Creating todo");
    final Map<String, dynamic> formData = {
      'title': title,
      'content': content,
      'isDone': isDone,
      'userId': _user.id,
    };
    print("For user:" + _user.id);
    try {
      // final http.Response response = await http.post(
      //   '${Configure.FirebaseUrl}/todos.json?auth=${_user.token}',
      //   body: json.encode(formData),
      // );

      // if (response.statusCode != 200 && response.statusCode != 201) {
      //   _isLoading = false;
      //   notifyListeners();

      //   return false;
      // }

      // final Map<String, dynamic> responseData = json.decode(response.body);

      Todo todo = Todo(
        id: 0,
        // id: responseData['name'],
        title: title,
        content: content,
        isDone: isDone
      );
      _todos.add(todo);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> updateTodo(
      String newTitle, 
      String newContent
      ) async {


    _isLoading = true;
    notifyListeners();

    // final Map<String, dynamic> formData = {
    //   'title': title,
    //   'content': content,
    // };

    // print("formData:");
    // print(formData);
    // print(json.encode(formData));

    // try {
      //TODO: create new note
      // final http.Response response = await http.put(
      //   '${Configure.FirebaseUrl}/todos/${currentTodo.id}.json?auth=${_user.token}',
      //   body: json.encode(formData),
      // );

      // if (response.statusCode != 200 && response.statusCode != 201) {
      //   _isLoading = false;
      //   notifyListeners();
      //   // return false;
      // }

      Todo todo = Todo(
        id: currentTodo.id,
        title: newTitle,
        content: newContent,
        image: currentTodo.image,
        snoozed: currentTodo.snoozed,
        snoozedTime: currentTodo.snoozedTime,
        snoozedDate: currentTodo.snoozedDate,
        tags: currentTodo.tags
      );

      int todoIndex = _todos.indexWhere((t) => t.id == currentTodo.id);
      _todos[todoIndex] = todo;

     final bool success = await pushNotes();
          _isLoading = false;
          notifyListeners();
          return success;
    // } catch (error) {
    // }
}
                  
Future<bool> removeTodo(int id) async {
  _isLoading = true;
  notifyListeners();

  try {
    Todo todo = _todos.firstWhere((t) => t.id == id);
    int todoIndex = _todos.indexWhere((t) => t.id == id);
    _todos.removeAt(todoIndex);

    final http.Response response = await http.delete(
        '${Configure.FirebaseUrl}/todos/$id.json?auth=${_user.token}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      _todos[todoIndex] = todo;

      _isLoading = false;
      notifyListeners();

      return false;
    }

    _isLoading = false;
    notifyListeners();

    return true;
  } catch (error) {
    _isLoading = false;
    notifyListeners();

    return false;
  }
}

Future<bool> toggleDone(int id) async {
  print("Toggle done");
  _isLoading = true;
  notifyListeners();

  Todo todo = _todos.firstWhere((t) => t.id == id);

  final Map<String, dynamic> formData = {
    'title': todo.title,
    'content': todo.content,
    'isDone': !todo.isDone,
    'userId': _user.id,
  };

  try {
    final http.Response response = await http.put(
      '${Configure.FirebaseUrl}/todos/$id.json?auth=${_user.token}',
      body: json.encode(formData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      _isLoading = false;
      notifyListeners();

      return false;
    }

    todo = Todo(
      id: todo.id,
      title: todo.title,
      content: todo.content,
      isDone: !todo.isDone
    );
    int todoIndex = _todos.indexWhere((t) => t.id == id);
    _todos[todoIndex] = todo;

    _isLoading = false;
    notifyListeners();

    return true;
  } catch (error) {
    _isLoading = false;
    notifyListeners();
    return false;
    }
  }

Future<bool> pushNotes() async {

  List jsonList = List();
  int currentId = 0;
  var it = _todos.iterator;
  while (it.moveNext()) {
    while (it.current.id !=currentId) {
      jsonList.add("null");
      currentId++;
    }
    jsonList.add(it.current.toJson());
    currentId++;
  }

  final String notes = jsonList.toString();
  final String url = "http://192.168.2.38/server.php";

  final String data = '{ "cmd" : "push_notes", "notes" : ' + notes + '}';

  final http.Response response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: data 
  );

  if (response.statusCode != 200 && response.statusCode != 201) {
    print("not 200 or 201 status code");
    return false;
  } 

  // try {
    final Map <String, dynamic> decoded =  json.decode(response.body); 
    final String success = decoded['success'];
    return success == "true";
  // } catch (e) {
    // print("sorry boy");
    // return false;
  // }
}

      
}




mixin UserModel on CoreModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();
  var defUser = User( id: "0", email: "s@gmail.com", token: "s");

  User get user {
    return defUser;
    // return _user;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(
      String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> formData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };



    try {
      final http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=${Configure.ApiKey}',
        body: json.encode(formData),
        headers: {'Content-Type': 'application/json'},
      );


      final Map<String, dynamic> responseData = json.decode(response.body);
      String message;

      if (responseData.containsKey('idToken')) {

        _user = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
        );

        setAuthTimeout(int.parse(responseData['expiresIn']));

        final DateTime now = DateTime.now();
        final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', responseData['localId']);
        prefs.setString('email', responseData['email']);
        prefs.setString('token', responseData['idToken']);
        prefs.setString('refreshToken', responseData['refreshToken']);
        prefs.setString('expiryTime', expiryTime.toIso8601String());

        _userSubject.add(true);

        _isLoading = false;
        notifyListeners();

        // return {'success': true};
      } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
        message = 'Email is not found.';
      } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
        message = 'Password is invalid.';
      } else if (responseData['error']['message'] == 'USER_DISABLED') {
        message = 'The user account has been disabled.';
      }

      _isLoading = false;
      notifyListeners();

      return {'success': true};
      return {
        'success': false,
        'message': message,
      };
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return {'success': false, 'message': error};
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final Map<String, dynamic> formData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    try {
      final http.Response response = await http.post(
        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=${Configure.ApiKey}',
        body: json.encode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      String message;

      if (responseData.containsKey('idToken')) {
        // return {'success': true};
        _user = User(
          id: responseData['localId'],
          email: responseData['email'],
          token: responseData['idToken'],
        );

        setAuthTimeout(int.parse(responseData['expiresIn']));

        final DateTime now = DateTime.now();
        final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(responseData['expiresIn'])));

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', responseData['localId']);
        prefs.setString('email', responseData['email']);
        prefs.setString('token', responseData['idToken']);
        prefs.setString('refreshToken', responseData['refreshToken']);
        prefs.setString('expiryTime', expiryTime.toIso8601String());

        _userSubject.add(true);

        _isLoading = false;
        notifyListeners();

        return {'success': true};
      } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
        message = 'Email is already exists.';
      } else if (responseData['error']['message'] == 'OPERATION_NOT_ALLOWED') {
        message = 'Password sign-in is disabled.';
      } else if (responseData['error']['message'] ==
          'TOO_MANY_ATTEMPTS_TRY_LATER') {
        message =
            'We have blocked all requests from this device due to unusual activity. Try again later.';
      }

      _isLoading = false;
      notifyListeners();
      return {'success': true};

      return {
        'success': false,
        'message': message,
      };
    } catch (error) {
      _isLoading = false;
      notifyListeners();

      return {'success': false, 'message': error};
    }
  }

  void logout() async {
    _todos = [];
    _todo = null;
    _filter = Filter.All;
    _user = null;

    _authTimer.cancel();

    _userSubject.add(false);

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void autoAuthentication() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');

    if (token != null) {
      final String expiryTimeString = prefs.getString('expiryTime');
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);

      if (parsedExpiryTime.isBefore(now)) {
        _user = null;

        return;
      }

      _user = User(
        id: prefs.getString('userId'),
        email: prefs.getString('email'),
        token: token,
      );

      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
      setAuthTimeout(tokenLifespan);

      _userSubject.add(true);
    }
  }

  void tryRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refreshToken');

    final Map<String, dynamic> formData = {
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken
    };

    try {
      final http.Response response = await http.post(
        'https://securetoken.googleapis.com/v1/token?key=${Configure.ApiKey}',
        body: json.encode(formData),
        headers: {'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('id_token')) {
        _user = User(
          id: prefs.getString('userId'),
          email: prefs.getString('email'),
          token: responseData['id_token'],
        );

        setAuthTimeout(int.parse(responseData['expires_in']));

        final DateTime now = DateTime.now();
        final DateTime expiryTime =
            now.add(Duration(seconds: int.parse(responseData['expires_in'])));

        prefs.setString('token', responseData['id_token']);
        prefs.setString('expiryTime', expiryTime.toIso8601String());
        prefs.setString('refreshToken', responseData['refresh_token']);

        print('tryRefreshToken');

        return;
      }
    } catch (error) {}

    logout();
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), tryRefreshToken);
  }
}

mixin SettingsModel on CoreModel {
  Settings _settings;
  PublishSubject<bool> _themeSubject = PublishSubject();

  Settings get settings {
    return _settings;
  }

  PublishSubject<bool> get themeSubject {
    return _themeSubject;
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkThemeUsed = _loadIsDarkThemeUsed(prefs);

    print("is Shortcuts enabled");
    _settings = Settings(
      isShortcutsEnabled: _loadIsShortcutsEnabled(prefs),
      isDarkThemeUsed: isDarkThemeUsed,
    );

    _themeSubject.add(isDarkThemeUsed);
  }

  bool _loadIsShortcutsEnabled(SharedPreferences prefs) {
    return prefs.getKeys().contains('isShortcutsEnabled') &&
            prefs.getBool('isShortcutsEnabled')
        ? true
        : false;
  }

  bool _loadIsDarkThemeUsed(SharedPreferences prefs) {
    return prefs.getKeys().contains('isDarkThemeUsed') &&
            prefs.getBool('isDarkThemeUsed')
        ? true
        : false;
  }

  Future toggleIsShortcutEnabled() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isShortcutsEnabled', !_loadIsShortcutsEnabled(prefs));

    _settings = Settings(
      isShortcutsEnabled: _loadIsShortcutsEnabled(prefs),
      isDarkThemeUsed: _loadIsDarkThemeUsed(prefs),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future toggleIsDarkThemeUsed() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final isDarkThemeUsed = !_loadIsDarkThemeUsed(prefs);
    prefs.setBool('isDarkThemeUsed', isDarkThemeUsed);

    _themeSubject.add(isDarkThemeUsed);

    _settings = Settings(
      isShortcutsEnabled: _loadIsShortcutsEnabled(prefs),
      isDarkThemeUsed: _loadIsDarkThemeUsed(prefs),
    );

    _isLoading = false;
    notifyListeners();
  }
}
