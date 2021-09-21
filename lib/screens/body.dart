import 'package:connect2care/screens/add_listing.dart';
import 'package:connect2care/screens/all_listings.dart';
import 'package:connect2care/screens/chat_screen.dart';
import 'package:connect2care/screens/my_listings.dart';
import 'package:connect2care/src/Widget/bezierContainer.dart';
import 'package:connect2care/widgets/category_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentCategory = 0;
  void changeCategory(int val) {
    setState(() {
      currentCategory = val;
    });
  }

  void logout() async {
    print('logout Pressed');
    print(FirebaseAuth.instance.currentUser!.uid);
    await FirebaseAuth.instance.signOut();
    print(FirebaseAuth.instance.currentUser!.uid);
    // Navigator.of(context).pushNamed('');
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final widgets = [
      AllListings(),
      ChatScreen(),
      AddListing(),
      MyListings(),
      SizedBox(),
    ];

    print(FirebaseAuth.instance.currentUser!.uid);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // height: height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer(),
                ),
                Column(
                  children: [
                    //Categories
                    CategoryPicker(
                      changeCategory: changeCategory,
                      currentCategory: currentCategory,
                    ),
                    //Widget that gets selected from category picker
                    widgets[currentCategory],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
