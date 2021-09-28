import 'package:connect2care/screens/body.dart';
import 'package:connect2care/screens/chat.dart';
import 'package:connect2care/src/welcomePage.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connect2Care',
      home: Body(),
      //  StreamBuilder(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (ctx, userSnapShot) {
      //     if (userSnapShot.hasData) {
      //       return Body();
      //     }
      //     return WelcomePage();
      //   },
      // ),
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
