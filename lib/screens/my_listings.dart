import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect2care/widgets/listing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MyListings extends StatelessWidget {
  const MyListings({Key? key}) : super(key: key);
  void deleteListing(String id, context) async {
    try {
      await FirebaseFirestore.instance.collection('listings').doc(id).delete();
    } on PlatformException catch (err) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('$err'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          });
    } catch (err) {
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('$err'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Okay'),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: double.infinity,
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: 0),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('listings')
              .orderBy('timestamp')
              .snapshots(),
          builder:
              (ctx, AsyncSnapshot<QuerySnapshot<dynamic>> listingSnapShots) {
            if (listingSnapShots.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            final listings = listingSnapShots.data!.docs;
            // print(listings);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(6),
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'My Listings',
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
                        if (listings[index]['userId'] == userId)
                          return Dismissible(
                            key: ValueKey(listings[index].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: EdgeInsets.all(10),
                              padding: EdgeInsets.all(20),
                              color: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                              alignment: Alignment.centerRight,
                            ),
                            confirmDismiss: (direction) {
                              return showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return AlertDialog(
                                      title: Text(
                                          'Are you sure you want to delete this?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: Text('Yes'),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            onDismissed: (direction) {
                              deleteListing(listings[index].id, context);
                            },
                            child: Listing(
                              docId: listings[index].id,
                              category: listings[index]['category'],
                              title: listings[index]['title'],
                              description: listings[index]['description'],
                              location: listings[index]['location'],
                              willpay: listings[index]['willPay'],
                              amount: listings[index]['amount'],
                              edit: true,
                            ),
                          );
                        else
                          return SizedBox();
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
