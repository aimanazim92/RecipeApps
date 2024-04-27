

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/views/profile_view.dart';
import 'package:untitled/views/recipe_list_view.dart';

import '../components/color.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {

  HomeScreen ({Key? key}) : super (key : key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  String? cat ="";


  User? user = FirebaseAuth.instance.currentUser;

  UserModel loggedInUser = UserModel();

  @override
  void initState(){
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {

      });
    });

  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      RecipeListView(),
      ProfileView(),
    ];

    final items = <Widget>[
      const Icon(Icons.home,size: 30,color: Colors.white),
      const Icon(Icons.person,size: 30,color: Colors.white),
    ];

    return  Scaffold(

      backgroundColor: kPrimaryColor,
      body: screens[index],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: kSecondaryColor,
        color: kSecondaryColor,
        height: 50 ,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 200),
        index: index,
        items: items,
        onTap: (index) => setState(() => this.index = index),
      ),

    );
  }

}