import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryPicker extends StatelessWidget {
  final currentCategory;
  final changeCategory;
  CategoryPicker({this.currentCategory, this.changeCategory});
  Widget _buildListTile(
      String title, int val, IconData icon, BuildContext context) {
    return InkWell(
      onTap: () async {
        if (title.toUpperCase() == 'logout'.toUpperCase()) {
          print('Logging Out');
          await FirebaseAuth.instance.signOut();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else
          changeCategory(val);
      },
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                  color: currentCategory == val
                      ? Theme.of(context).primaryColor
                      : Colors.white),
              borderRadius: BorderRadius.circular(33),
            ),
            margin: EdgeInsets.symmetric(horizontal: 6),
            child: CircleAvatar(
              child: Icon(
                icon,
                color: currentCategory == val
                    ? Theme.of(context).primaryColor
                    : Colors.white,
              ),
              radius: 33,
              backgroundColor:
                  currentCategory == val ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.portLligatSans(
              color: currentCategory == val
                  ? Colors.black
                  : Theme.of(context).primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildListTile('Home', 0, Icons.home, context),
          SizedBox(
            width: 20,
          ),
          _buildListTile('Chat', 1, Icons.message_outlined, context),
          SizedBox(
            width: 20,
          ),
          _buildListTile('Add Listing', 2, Icons.add, context),
          SizedBox(
            width: 20,
          ),
          _buildListTile('My Listing', 3, Icons.list, context),
          SizedBox(
            width: 20,
          ),
          _buildListTile('Logout', 4, Icons.logout, context),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }
}
