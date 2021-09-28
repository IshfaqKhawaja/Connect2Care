import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect2care/src/Widget/bezierContainer.dart';
import 'package:connect2care/src/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  Map _details = {
    'username': '',
    'email': '',
    'password': '',
    'phone_no': '',
  };
  String? password;
  String? confirmPassword;
  bool isSigningUp = false;
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, String fieldValue,
      {bool isPassword = false,
      bool isPhone = false,
      bool isConfirmPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          TextFormField(
            obscureText: isPassword,
            decoration: InputDecoration(
              border: InputBorder.none,
              fillColor: Color(0xfff3f3f4),
              filled: true,
            ),
            validator: (val) {
              if (val!.isEmpty) {
                return 'Please enter a value';
              }
              if (isPhone) {
                if (val.length != 10) {
                  return 'Phone no should be 10 digits long';
                }
              }
              if (isPassword) {
                if (val.length < 7) {
                  return 'Password should be atleast 7 digits long';
                }
              }
              return null;
            },
            onChanged: (val) {
              if (isPassword && !isConfirmPassword) {
                password = val;
              } else if (isConfirmPassword) {
                confirmPassword = val;
              } else {
                _details[fieldValue] = val;
              }
            },
            keyboardType: isPhone ? TextInputType.phone : TextInputType.name,
          )
        ],
      ),
    );
  }

  Widget _submitButton(BuildContext ctx) {
    return InkWell(
      onTap: () async {
        bool isValid = _formKey.currentState!.validate();
        if (isValid) {
          _formKey.currentState!.save();
          print(password);
          print(confirmPassword);
          if (password!.toUpperCase() == confirmPassword!.toUpperCase()) {
            _details['password'] = password;
            print(_details);
            try {
              setState(() {
                isSigningUp = true;
              });
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: _details['email'], password: _details['password']);
              final userId = FirebaseAuth.instance.currentUser!.uid;
              print(userId);
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .set({'details': _details});
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/body', (route) => false);
              setState(() {
                isSigningUp = false;
              });
            } on PlatformException catch (err) {
              await showDialog(
                context: ctx,
                builder: (ctx) => AlertDialog(
                  content: Text('$err'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'),
                    ),
                  ],
                ),
              );
              setState(() {
                isSigningUp = false;
              });
            } catch (err) {
              await showDialog(
                context: ctx,
                builder: (ctx) => AlertDialog(
                  content: Text('$err'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Okay'),
                    ),
                  ],
                ),
              );
              setState(() {
                isSigningUp = false;
              });
            }
          } else {
            showDialog(
              context: ctx,
              builder: (ctx) => AlertDialog(
                content: Text('Password and Confirm Password Should be same'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'),
                  ),
                ],
              ),
            );
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Theme.of(context).primaryColor, Color(0xfff7892b)])),
        child: isSigningUp
            ? CircularProgressIndicator()
            : Text(
                'Register Now',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Login',
              style: TextStyle(
                  color: Color(0xfff79c4f),
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'Connect',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.display1,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Color(0xffe46b10),
          ),
          children: [
            TextSpan(
              text: '2',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'Care',
              style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            ),
          ]),
    );
  }

  Widget _emailPasswordWidget() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _entryField("Username", 'username'),
          _entryField("Email id", 'email'),
          _entryField("Password", 'password', isPassword: true),
          _entryField("Confirm Password", 'password',
              isPassword: true, isConfirmPassword: true),
          _entryField("Phone No", 'phone_no', isPhone: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -MediaQuery.of(context).size.height * .15,
              right: -MediaQuery.of(context).size.width * .4,
              child: BezierContainer(),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    _emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    _submitButton(context),
                    SizedBox(height: 10),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
