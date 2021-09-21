import 'package:connect2care/screens/body.dart';
import 'package:connect2care/src/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Logout extends StatefulWidget {
  const Logout({Key? key}) : super(key: key);

  @override
  _LogoutState createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    logout();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
