import 'package:connect2care/screens/body.dart';
import 'package:connect2care/screens/chat.dart';
import 'package:connect2care/screens/splash_screen.dart';
import 'package:connect2care/src/welcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool init = true;

  void changeInit() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() => init = false);
  }

  @override
  void initState() {
    super.initState();
    changeInit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connect2Care',
      home: init
          ? SplashScreen()
          : StreamBuilder(
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
    );
  }
}
