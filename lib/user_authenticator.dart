import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:myapp/core/configuration.dart';
import 'package:myapp/core/event_bus.dart';

import 'events/user_authenticated_event.dart';

class UserAuthenticator {
  final _dio = Dio();
  final _logger = Logger();

  UserAuthenticator._privateConstructor();

  static final UserAuthenticator instance =
      UserAuthenticator._privateConstructor();

  Future<bool> login(String username, String password) {
    return _dio.post(
        "http://" + Configuration.instance.getEndpoint() + ":8080/users/login",
        queryParameters: {
          "username": username,
          "password": password
        }).then((response) {
      if (response.statusCode == 200 && response.data != null) {
        Configuration.instance.setUsername(username);
        Configuration.instance.setPassword(password);
        Configuration.instance.setToken(response.data["token"]);
        Bus.instance.fire(UserAuthenticatedEvent());
        return true;
      } else {
        return false;
      }
    }).catchError((e) {
      _logger.e(e.toString());
      return false;
    });
  }
}
