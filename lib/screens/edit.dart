import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:group_radio_button/group_radio_button.dart';

class Edit extends StatefulWidget {
  final docId;
  final locationDetails;
  final category;
  final title;
  final description;
  final willPay;
  final amount;
  Edit(
      {this.docId,
      this.locationDetails,
      this.category,
      this.title,
      this.description,
      this.willPay,
      this.amount});

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  var locationController = TextEditingController();
  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _amountController = TextEditingController();
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
  //remove done chip
  Future<void> removeDoneChip() async {
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      done = false;
    });
  }

  //get location
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

  void submitData(docId) async {
    // print(docId);
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
        if (!willPay) {
          amount = 0.0;
        }
        setState(() {
          isSubmitting = true;
        });
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final response = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        print(response['details']['username']);

        await FirebaseFirestore.instance
            .collection('listings')
            .doc(docId)
            .update({
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
        print(err);
      } catch (err) {
        setState(() {
          isSubmitting = false;
        });
        print(err);
      }
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    locationDetails = widget.locationDetails;
    locationController.text = locationDetails;
    category = widget.category;
    title = widget.title;
    _titleController.text = title;
    description = widget.description;
    _descriptionController.text = description;
    willPay = widget.willPay;
    amount = widget.amount;
    _amountController.text = '$amount';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(
              top: 10,
              left: 10,
              right: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 10),
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
                        'Updated',
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
                        onPressed: getLocation,
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
                      selectedItem: category,
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
                                    controller: _amountController,
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
                                  onPressed: () {
                                    submitData(widget.docId);
                                  },
                                  child: Text(
                                    'Update',
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
