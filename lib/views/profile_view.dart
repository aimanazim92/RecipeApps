import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/color.dart';
import '../components/profile_info.dart';
import '../components/profile_menu_item.dart';
import '../components/size_config.dart';
import '../models/user.dart';
import 'log_view.dart';

class ProfileView extends StatefulWidget {
   const ProfileView ({super.key});
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>{

  User? user = FirebaseAuth.instance.currentUser;
  String userID = FirebaseAuth.instance.currentUser!.uid;
  UserModel loggedInUser = UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  Future userUpdateName(String name, String userID) async{

    final CollectionReference profile = FirebaseFirestore.instance.collection('users');

    return await profile.doc(userID).update({'name':name} );
  }

  Future userUpdatePhone(String phone, String userID) async{

    final CollectionReference profile = FirebaseFirestore.instance.collection('users');

    return await profile.doc(userID).update({'phone':phone} );
  }

  Future userUpdateEmail(String email, String userID) async{

    final CollectionReference profile = FirebaseFirestore.instance.collection('users');
    final User? user = FirebaseAuth.instance.currentUser;

    await user?.updateEmail(email);

    return await profile.doc(userID).update({'email':email} );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: kSecondaryColor,
      leading: SizedBox(),
      // On Android it's false by default
      centerTitle: true,
      title: const Text("Profile"),
      foregroundColor: kTextLightColor,
      // actions: <Widget>[
      //   ElevatedButton(
      //     onPressed: () {},
      //     child: Text(
      //       "Edit",
      //       style: TextStyle(
      //         color: kSecondaryColor,
      //         fontSize: SizeConfig.defaultSize * 1.6, //16
      //         fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ),
      // ],
    );
  }

  //bottomSheet
  void bottomUsername(BuildContext e){

    String? cusername = loggedInUser.name;
    String? user_id = loggedInUser.uid;


    TextEditingController _usernameController = TextEditingController();
    _usernameController.value = TextEditingValue(
      text: cusername!,
    );
    showModalBottomSheet(
        isScrollControlled:true,
        context: e,
        builder: (e) => Padding
          (padding: EdgeInsets.only(
            top:15,
            left:15,
            right:15,
            bottom: MediaQuery.of(e).viewInsets.bottom +15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Name",
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [

                  ElevatedButton(onPressed: () async{
                    await userUpdateName(_usernameController.text, user_id!);
                    Fluttertoast.showToast(msg:"Succesfully");
                    Navigator.pop(context);
                  },
                      child: const Text('Submit')),
                  SizedBox(width: 20,),
                  ElevatedButton(onPressed: () async{
                    Navigator.pop(context);
                  },
                      child: const Text('Back')),
                ],
              )
            ],
          ),
        )
    );
  }

  void bottomEmail(BuildContext e){

    String? cuseremail = loggedInUser.email;
    String? user_id = loggedInUser.uid;


    TextEditingController _emailController = TextEditingController();
    _emailController.value = TextEditingValue(
      text: cuseremail!,
    );

    showModalBottomSheet(
        isScrollControlled:true,
        context: e,
        builder: (e) => Padding
          (padding: EdgeInsets.only(
            top:15,
            left:15,
            right:15,
            bottom: MediaQuery.of(e).viewInsets.bottom +15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {
                    userUpdateEmail(_emailController.text, user_id!);
                    Fluttertoast.showToast(msg:"Succesfully");
                    Navigator.pop(context);
                  }, child: const Text('Submit')),
                  SizedBox(width: 20,),
                  ElevatedButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: const Text('Back')),
                ],
              )
            ],
          ),
        )
    );
  }

  void bottomPhone(BuildContext e){

    String? cuserphone = loggedInUser.phone;
    String? user_id = loggedInUser.uid;


    final TextEditingController _phoneController = TextEditingController();

    _phoneController.value = TextEditingValue(
      text: cuserphone!,
    );

    showModalBottomSheet(
        isScrollControlled:true,
        context: e,
        builder: (e) => Padding
          (padding: EdgeInsets.only(
            top:15,
            left:15,
            right:15,
            bottom: MediaQuery.of(e).viewInsets.bottom +15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone",
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  ElevatedButton(onPressed: () {
                    userUpdatePhone(_phoneController.text, user_id!);
                    Fluttertoast.showToast(msg:"Succesfully");
                    Navigator.pop(context);
                  }, child: const Text('Submit')),
                  SizedBox(width: 20,),
                  ElevatedButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: const Text('Back')),
                ],
              )
            ],
          ),
        )
    );
  }

  Future <void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.remove('email');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder)=> const SimpleLoginScreen()), (route) => false);
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed:  () {
        logout(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Log Out Account"),
      content: Text("Are you sure want to log out from account?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String? id = loggedInUser.uid;
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(),
      body:
      StreamBuilder(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot>  streamSnapshot){
            if(streamSnapshot.hasData){
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context,index){
                    final DocumentSnapshot documentSnapshot = (streamSnapshot.data!.docs[index]);
                    if(documentSnapshot['uid'] == id){
                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                             Info(
                              image: "assets/profile_icon.jpg",
                              name: "${documentSnapshot['name']}",
                              email: "${documentSnapshot['email']}",
                            ),
                            SizedBox(height: SizeConfig.defaultSize * 4), //20
                            Card(
                              color: kSecondaryColor,
                              elevation: 5,
                              shape:  RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(35)
                              ),
                              child: ListTile(
                                title: const Text('Log Out',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white,
                                        fontWeight: FontWeight.bold
                                    )),
                                onTap:(){
                                  showAlertDialog(context);
                                } ,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

      ),


    );
  }


}


