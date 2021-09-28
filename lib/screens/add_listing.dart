import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart' as PH;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:geolocator/geolocator.dart';

class AddListing extends StatefulWidget {
  const AddListing({Key? key}) : super(key: key);

  @override
  _AddListingState createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {
  var locationController = TextEditingController();
  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  bool isLocated = false;
  bool isSubmitting = false;
  bool done = false;
  //DropDown Items
  List<String> dropdownItems = [
    'Blood/Plasma Donation',
    'Medicine Delivery',
    'Call Ambulance',
    'Courier Service',
    'Need CareTaker',
    'Need Tutor',
    'Grocery Delivery',
    'Food Delivery'
  ];
  //Details
  String locationDetails = '';
  String category = '';
  String title = '';
  String description = '';
  bool willPay = true;
  double amount = 0.0;
  PH.PermissionStatus? _permissionStatus;
  //remove done chip
  Future<void> removeDoneChip() async {
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      done = false;
    });
  }

  //Ask for Permission to use Location
  Future<void> requestPermission(PH.Permission permission) async {
    final status = await permission.request();

    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  //Using Geolocator
  void _determinePosition() async {
    var permissionStatus = await PH.Permission.location.status;
    if (permissionStatus.isGranted) {
      print('Requersting Permission');
      await PH.Permission.location.request();
    }

    Position _locationData;
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      setState(() {
        isLocated = true;
      });
      _locationData = await Geolocator.getCurrentPosition(
        forceAndroidLocationManager: true,
      );
      final logitude = _locationData.longitude;
      final latitude = _locationData.latitude;
      print('Latitude is $latitude');
      print('Logitude is $logitude');

      // locationController.text = '$latitude' + ' ' + '$logitude';
      // final url =
      //     'http://api.positionstack.com/v1/forward?access_key=30c1a4340d593a6cdc9226f396cc09e6&query=$latitude,$logitude';
      //'http://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$logitude&sensor=true/false'
      final url =
          'https://api.opencagedata.com/geocode/v1/json?q=$latitude,$logitude&key=b1639b97045940d7a8aca4067744a5e0';
      print(url);
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      // print(data['results'][0]['components']);
      setState(() {
        locationController.text = data['results'][0]['formatted'];
      });
      print(locationController.text);
      setState(() {
        isLocated = false;
      });
    } catch (err) {
      setState(() {
        isLocated = false;
      });
    }
  }

  //get location using locations
  void getLocation() async {
    LocationData? _locationData;
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      isLocated = true;
    });
    try {
      _locationData = await location.getLocation();
      final logitude = _locationData.longitude;
      final latitude = _locationData.latitude;
      print('Latitude is $latitude');
      print('Logitude is $logitude');
      // final url =
      //     'http://api.positionstack.com/v1/forward?access_key=30c1a4340d593a6cdc9226f396cc09e6&query=$latitude,$logitude';
      //'http://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$logitude&sensor=true/false'
      final url =
          'https://api.opencagedata.com/geocode/v1/json?q=$latitude,$logitude&key=b1639b97045940d7a8aca4067744a5e0';
      print(url);
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      // print(data['results'][0]['components']);
      setState(() {
        locationController.text = data['results'][0]['components']['building'] +
            ' , ' +
            data['results'][0]['components']['city'];
      });
      print(locationController.text);
      setState(() {
        isLocated = false;
      });
    } catch (err) {
      setState(() {
        isLocated = false;
      });
    }
  }

  final _formKey = GlobalKey<FormState>();
  var _groupValue = 'Yes';

  void submitData() async {
    FocusScope.of(context).unfocus();
    bool isvalid = _formKey.currentState!.validate();
    if (isvalid) {
      _formKey.currentState!.save();
      try {
        if (locationDetails.isEmpty) {
          locationDetails = locationController.text;
        }
        if (category.isEmpty) {
          category = dropdownItems[0];
        }
        setState(() {
          isSubmitting = true;
        });
        final userId = FirebaseAuth.instance.currentUser!.uid;
        print('Where the hell is Error $userId');
        final response = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        print('Response is ${response['details']['username']}');

        await FirebaseFirestore.instance.collection('listings').add({
          'location': locationDetails,
          'category': category,
          'title': title,
          'description': description,
          'willPay': willPay,
          'amount': amount,
          'timestamp': Timestamp.now(),
          'userId': userId,
          'username': response['details']['username'],
        });

        setState(() {
          done = true;

          isSubmitting = false;
          _titleController.text = '';
          _descriptionController.text = '';
        });
        removeDoneChip();
      } on PlatformException catch (err) {
        setState(() {
          isSubmitting = false;
        });
        print('Error is $err');
      } catch (err) {
        setState(() {
          isSubmitting = false;
        });
        print('Final Error is $err');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(20),
          child: Card(
            elevation: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //If post is added:
                  if (done)
                    Chip(
                      backgroundColor: Colors.green,
                      label: Text(
                        'Uploaded',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isLocated
                          ? Container(
                              height: 20,
                              width: 20,
                              margin: EdgeInsets.all(10),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : Expanded(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: TextFormField(
                                  controller: locationController,
                                  decoration: InputDecoration(
                                    labelText: 'Location',
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return 'Please Enter a location';
                                    }
                                    return null;
                                  },
                                  onChanged: (val) {
                                    locationDetails = val;
                                  },
                                ),
                              ),
                            ),
                      if (isLocated) Spacer(),
                      IconButton(
                        onPressed: _determinePosition, //getLocation,
                        icon: Icon(
                          Icons.room_outlined,
                          color: locationController.text.isEmpty
                              ? null
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: DropdownSearch<String>(
                      mode: Mode.DIALOG,
                      showSelectedItem: true,
                      items: dropdownItems,
                      label: "Categories",
                      hint: "Categories",
                      popupItemDisabled: (String s) => s.startsWith('I'),
                      onChanged: (val) {
                        category = val!;
                      },
                      selectedItem: dropdownItems[0],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      keyboardType: TextInputType.text,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please Enter a title';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        title = val;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please Enter a description';
                        }
                        return null;
                      },
                      onChanged: (val) {
                        description = val;
                      },
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Do you want to pay for help?',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        RadioGroup<String>.builder(
                          groupValue: _groupValue,
                          onChanged: (String? value) => setState(() {
                            _groupValue = value!;
                            value.toUpperCase() == 'YES'
                                ? willPay = true
                                : willPay = false;
                            print(willPay);
                          }),
                          items: ['Yes', 'No'],
                          itemBuilder: (item) => RadioButtonBuilder(
                            item,
                            textPosition: RadioButtonTextPosition.right,
                          ),
                        ),
                        if (_groupValue.toUpperCase() == 'YES')
                          Row(
                            children: [
                              Container(
                                color: Colors.purple,
                                padding: EdgeInsets.all(6),
                                child: Text(
                                  'Rs',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        InputDecoration(labelText: 'Amount'),
                                    validator: (val) {
                                      if (val!.isEmpty) {
                                        return 'Please sum of rupees you want to pay';
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      amount = double.parse(val);
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        SizedBox(height: 10),
                        Container(
                          child: isSubmitting
                              ? CircularProgressIndicator()
                              : MaterialButton(
                                  onPressed: submitData,
                                  child: Text(
                                    'Submit',
                                    style: GoogleFonts.roboto(
                                      color: Colors.white,
                                    ),
                                  ),
                                  color: Theme.of(context).errorColor,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
