import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect2care/widgets/listing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AllListings extends StatefulWidget {
  const AllListings({Key? key}) : super(key: key);

  @override
  _AllListingsState createState() => _AllListingsState();
}

class _AllListingsState extends State<AllListings> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        margin: EdgeInsets.all(8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 0),
          // gradient: LinearGradient(
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //     colors: [Colors.white, Color(0xffe46b10)]),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('listings')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder:
              (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> listingSnapShots) {
            if (listingSnapShots.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final listings = listingSnapShots.data!.docs;
            print(listings);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'All Listings',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: listings.length,
                      itemBuilder: (ctx, index) {
                        return Listing(
                          docId: listings[index].id,
                          category: listings[index]['category'],
                          title: listings[index]['title'],
                          description: listings[index]['description'],
                          location: listings[index]['location'],
                          willpay: listings[index]['willPay'],
                          amount: listings[index]['amount'],
                          userId: userId,
                          recieverId: listings[index]['userId'],
                          username: listings[index]['username'],
                          edit: false,
                        );
                      }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
