import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/views/home_view.dart';
import 'package:untitled/views/log_view.dart';
import 'package:untitled/views/recipe_list_view.dart';

import 'components/color.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  if(Firebase.apps.length == 0){
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  }

  runApp( MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

}
class _MyAppState extends State<MyApp>{
  var email;


  @override
  void initState() {

    super.initState();
    checkLogin();
  }

  void checkLogin() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState((){
      email = preferences.getString('email');
    });

  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Recipe Apps',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: kPrimaryColor,
      ),
      home:
      email == null
      ? const SimpleLoginScreen() : HomeScreen(),
      //SimpleLoginScreen
    );
  }
}

