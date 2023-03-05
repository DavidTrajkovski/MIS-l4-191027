import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId; // logged in user
  Timer? _authTimer;

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
        _token != null) {
      return _token!;
    }
    return "";
  }

  bool get isAuthenticated {
    return token != "";
  }

  String get userId {
    return _userId!;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBeRmDHwyH0hLL0QdY-KVteJyPpg-_YiZI');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );

      _autoLogout();

      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate!.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
      print(userData);
    } catch (err) {
      rethrow;
    }

    //store registered user in realtime database
    if (urlSegment == 'signUp') {
      final storeUrl = Uri.parse(
          'https://examplanner-38b10-default-rtdb.firebaseio.com/users.json?auth=$_token');
      try {
        final response1 = await http.post(
          storeUrl,
          body: json.encode({'email': email, 'userId': _userId}),
        );
      } catch (err) {
        rethrow;
      }
    }
    print("hellooooo");
    
    //dummy data storing
    //
    // final storeUrl = Uri.parse(
    //     'https://examplanner-38b10-default-rtdb.firebaseio.com/exams.json?auth=$_token');
    // try {
    //   final response1 = await http.post(
    //     storeUrl,
    //     body: json.encode({
    //       'subjectName': 'fizika',
    //       'date': DateTime.now().toIso8601String(),
    //       'time': TimeOfDay.now().toString().substring(10,15)
    //     }),
    //   );
    // } catch (err) {
    //   rethrow;
    // }
  }

  Future<void> register(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  // void logout() {
  //   _token = null;
  //   _userId = null;
  //   _expiryDate = null;
  //   _authTimer!.cancel();
  //   _authTimer = null;
  //   notifyListeners();
  // }

 

  void logout() async {
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    _token = null;
    _userId = null;
    _expiryDate = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }

    final timeToExpiry = _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
