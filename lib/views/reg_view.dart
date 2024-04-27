import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../components/color.dart';
import '../components/field_text.dart';
import '../components/form_button.dart';
import '../models/user.dart';

class SimpleRegisterScreen extends StatefulWidget {

  /// Callback for when this form is submitted successfully. Parameters are (email, password)
  final Function(String? email, String? password, String name, String gender, String phone)? onSubmitted;
  const SimpleRegisterScreen({this.onSubmitted, super.key});

  @override
  _SimpleRegisterScreenState createState() => _SimpleRegisterScreenState();
}

class _SimpleRegisterScreenState extends State<SimpleRegisterScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isHidden = true;
  late String email, password, name, gender, phone, confirmPassword;
  String? emailError, passwordError, nameError, genderError, phoneError;
  Function(String? email, String? password, String name, String gender, String phone)? get onSubmitted =>
      widget.onSubmitted;

  @override
  void initState() {
    super.initState();
    email = "";
    password = "";
    name = "";
    gender = "";
    phone = "";
    confirmPassword = "";


    nameError = null;
    genderError = null;
    phoneError = null;
    emailError = null;
    passwordError = null;
  }

  void resetErrorText() {
    setState(() {
      emailError = null;
      passwordError = null;
      nameError = null;
      genderError = null;
      phoneError = null;
    });
  }

  bool validate() {
    resetErrorText();
    RegExp emailExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    RegExp pass = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{6,}$');
    // RegExp emailExp = RegExp(
    //     r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    RegExp phoneExp = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
    RegExp nameExp = RegExp('[a-zA-Z]');
    bool isValid = true;
    if (email.isEmpty || !emailExp.hasMatch(email)) {
      setState(() {
        emailError = "Email is invalid";
      });
      isValid = false;
    }
    if (name.isEmpty || !nameExp.hasMatch(name)){
      setState(() {
        nameError = "Please insert your name";
      });
      isValid = false;
    }
    if (gender.isEmpty){
      setState(() {
        genderError = "Please select your gender";
      });
    }
    if (phone.isEmpty || !phoneExp.hasMatch(phone)){
      setState(() {
        phoneError = "phone number is invalid";
      });
      isValid = false;
    }
    if (password.isEmpty || confirmPassword.isEmpty || !pass.hasMatch(password)) {
      setState(() {
        passwordError = "Please enter a valid password";
      });
      isValid = false;
    }
    if (password != confirmPassword) {
      setState(() {
        passwordError = "Passwords do not match";
      });
      isValid = false;
    }

    return isValid;
  }

  Future <void> submit() async{
    if (validate()) {
      try{
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: email, password: password).then((value) => {postDetailsToFirestore()});
        if (newUser != null) {

          Navigator.of(context).popUntil((route) => route.isFirst);

          Fluttertoast.showToast(msg: "Account Created Successfully");
        }
      }on FirebaseAuthException catch (e){
        if(e.code == 'email-already-in-use'){
          Fluttertoast.showToast(msg: "The email has already exist, please choose another email");
        }
        else{
          Fluttertoast.showToast(msg: "The error is${e.message}/${e.code}");
        }
      }
    }
  }

  postDetailsToFirestore() async{


    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;


    UserModel userModel = UserModel();

    //write all value
    userModel.name = name;
    userModel.phone = phone;
    userModel.email = user!.email;
    userModel.uid = user.uid;

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

  }

  _togglePasswordView(){
    setState((){
      _isHidden = !_isHidden;
    });
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
              "Create Account,",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: screenHeight * .01),
            Text(
              "Sign up to get started!",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black.withOpacity(.6),
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
              autoFocus: true,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
              labelText: "Name",
              errorText: nameError,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            TextField(
              onChanged: (value) {
                setState(() {
                  password = value;
                });
              },
              textInputAction: TextInputAction.next,
              obscureText: _isHidden,
              decoration: InputDecoration(
                labelText: "Password",
                errorText: passwordError,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)
                ),
                suffix: InkWell(
                  onTap: _togglePasswordView,
                  child: Icon(
                    _isHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 17,
                  ),
                ),
              ),
            ),
            const Text(' The password must have more than 5 character, one Numeric Number, one Upper case, one lowercase',overflow: TextOverflow.visible,softWrap: true,textAlign: TextAlign.center ,style: TextStyle(color: Colors.black),),
            SizedBox(height: screenHeight * .025),
            TextField(
              onChanged: (value) {
                setState(() {
                  confirmPassword = value;
                });
              },
              onSubmitted: (value) => submit(),
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                suffix: InkWell(
                  onTap: _togglePasswordView,
                  child: Icon(
                    _isHidden
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 17,
                  ),
                ),
                errorText: passwordError,
              ),
              obscureText: _isHidden ,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),
            InputField(
              onChanged: (value) {
                setState(() {
                  phone = value;
                });
              },
              labelText: "Phone",
              errorText: phoneError,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(
              height: screenHeight * .075,
            ),
            FormButton(
              text: "Submit",
              onPressed: submit,
            ),
            SizedBox(
              height: screenHeight * .060,
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: RichText(
                text:  const TextSpan(
                  text: "I'm already a member, ",
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Sign In",
                      style: TextStyle(
                        color: kTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}