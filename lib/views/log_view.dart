
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/views/home_view.dart';
import 'package:untitled/views/reg_view.dart';

import '../components/color.dart';
import '../components/field_text.dart';
import '../components/form_button.dart';

class SimpleLoginScreen extends StatefulWidget {
  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password)? onSubmitted;

  const SimpleLoginScreen({this.onSubmitted, Key? key}) : super(key: key);
  @override
  _SimpleLoginScreenState createState() => _SimpleLoginScreenState();
}

final _auth =FirebaseAuth.instance;

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  late String email, password;
  bool _isHidden = true;

  String? emailError, passwordError;
  Function(String? email, String? password)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";

    emailError = null;
    passwordError = null;

  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
    });


  }




  bool validate() {
    resetErrorText();

    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");


    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "Email is invalid";
      });
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() {
        passwordError = "Please enter a password";
      });
      isValid = false;
    }

    return isValid;
  }

  _togglePasswordView(){
    setState((){
      _isHidden = !_isHidden;
    });
  }

  Future<void> submit() async {
    if (validate()) {
      try{
        final user = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        if (user != null) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          preferences.setString('email', email);
          Fluttertoast.showToast(msg: "Login Successfully");
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (builder)=>
            HomeScreen()
          ),
                  (route) => false);
        }
      } on FirebaseAuthException catch (e){
        if(e.code == 'user-not-found'){
          Fluttertoast.showToast(msg: "No user found for that email");
        } else if(e.code == 'wrong-password'){
          Fluttertoast.showToast(msg: "Wrong Password");
        }else if(e.code == 'user-disabled'){
          Fluttertoast.showToast(msg: "The User has been disabled");
        }
      }


    }
  }



  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: screenHeight * .12),
            const Text(
              "Welcome,",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kTextColor
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              "Sign in to continue!",
              style: TextStyle(
                fontSize: 18,
                color: kTextColor,
              ),
            ),
            SizedBox(height: screenHeight * .12),
            InputField(
              onChanged: (value) {
                setState(() {
                  email = value;
                });
              },
              labelText: "Email",
              errorText: emailError,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              onSubmitted: (val) => submit(),
              labelText: "Password",
              errorText: passwordError,
              obscureText: _isHidden,
              suffix: InkWell(
                onTap: _togglePasswordView,
                child: Icon(
                  _isHidden
                      ? Icons.visibility
                      : Icons.visibility_off,
                  size: 17,
                ),
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: screenHeight * .075,
            ),
            FormButton(

                text: "Log In",
                onPressed: submit
            ),
            SizedBox(
              height: screenHeight * .15,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SimpleRegisterScreen(),
                ),
              ),
              child: RichText(
                text:  const TextSpan(
                  text: "I'm a new user, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign Up",
                      style: TextStyle(
                        color: kTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





