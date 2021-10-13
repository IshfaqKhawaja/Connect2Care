import 'package:connect2care/screens/body.dart';
import 'package:connect2care/screens/chat.dart';
import 'package:connect2care/screens/home.dart';
import 'package:connect2care/src/welcomePage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
 

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connect2Care',
      home: Home(),
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.redAccent,
      ),
      routes: {
        '/body': (_) => Body(),
        Chat.routeName: (_) => Chat(),
        WelcomePage.routeName: (_) => WelcomePage(),
      },
    ),
  );
}
