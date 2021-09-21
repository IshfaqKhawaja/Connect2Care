import 'package:connect2care/screens/body.dart';
import 'package:connect2care/screens/chat.dart';
import 'package:connect2care/src/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connect2Care',
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapShot) {
          if (userSnapShot.hasData) {
            return Body();
          }
          return WelcomePage();
        },
      ),
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
