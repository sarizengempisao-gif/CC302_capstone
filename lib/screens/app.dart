import 'package:flutter/material.dart';

import '../models/index.dart';
import '../services/store.dart';
import 'admin_home.dart';
import 'login.dart';
import 'passenger_home.dart';

/// Top of the app's UI tree.
///
/// Shows [Login] when nobody is signed in, otherwise hands off to the home
/// screen that matches the signed-in user's [Role]. The [onDone] callback is
/// how login/logout tell the router that the signed-in user changed.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final user = Store.instance.current;
    if (user == null) return Login(onLoggedIn: _refresh);
    return user.role == Role.admin
        ? AdminHome(user: user, onDone: _refresh)
        : PassengerHome(user: user, onDone: _refresh);
  }
}
