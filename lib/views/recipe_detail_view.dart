import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/components/color.dart';
import 'package:untitled/views/home_view.dart';

import '../components/custom_back_button.dart';
import '../components/icon_text.dart';
import '../components/recipe_detail.dart';
import 'edit_recipe_view.dart';


class RecipeDetailView extends StatefulWidget {
  final String? recipeId;

  const RecipeDetailView({super.key, this.recipeId});

  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> with
    TickerProviderStateMixin{

  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference ref = FirebaseFirestore.instance.collection('recipes');
  dynamic data;
  String userid ="";
  late AnimationController controller;
  late Animation<double> animation;
  var categoryList = ['Appertizers','Main Course','Side Dishes','Beverages','Snacks',"Soups & Stews",'Bakery Items','Malay Cuisines','Chinese Cuisines',"Indian Cuisines"];

  @override
  void initState() {
    log(widget.recipeId!);
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInToLinear));
    controller.forward();
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Future<void> deleteRecipe(String recipeId) async {

    await FirebaseFirestore.instance.collection('recipes').doc(recipeId).delete();
    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  showAlertDialog(BuildContext context,String recipeId,String title) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Update"),
      onPressed:  () {
        ;
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Edit Recipe $title"),
      content: Text("Are you sure want to delete this recipe?"),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child:
          StreamBuilder<dynamic>(
            stream: ref.doc(widget.recipeId!).snapshots(),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return const Column(
                  children: [
                    Center(child: Text("The data is missing"),)
                  ],
                );
              }
              if(snapshot.hasData){
                log("DATA Recipe ${snapshot.data}");
                Map<String, dynamic> documentData = snapshot.data!.data();
                // List ingredients = documentData['ingredient'] as List<String>;
                // List instructions = documentData['instruction'] as List<String>;
                return Column(
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          documentData['imageUrl'],
                          height: 250.0,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 15.0,
                          left: 15.0,
                          child: CustomBackButton(),
                        ),
                        Positioned(
                          bottom: 0.0,
                          left: 0.0,
                          right: 0.0,
                          child: Container(
                            height: 15.0,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30.0),
                                topRight: Radius.circular(30.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 0.0,
                        bottom: 15.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            documentData['category'],
                            style: const TextStyle(
                              fontSize: 18.0,
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                documentData['title'],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: kTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                            ],
                          ),
                          const SizedBox(
                            height: 15.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconText(
                                icon: Icons.access_time,
                                text: '${documentData['cookTime']} mins',
                              ),
                              IconText(
                                icon:
                                documentData['category'] == 'Beverages'
                                    ? Icons.local_bar
                                    : Icons.room_service,
                                text: '${documentData['serving']} servings',
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(
                            thickness: 0.3,
                            color: Colors.black54,
                          ),
                          RecipeDetails(
                            title: 'Ingredients',
                            recipeInfo: documentData['ingredients'],
                          ),
                          RecipeDetails(
                            title: 'Cooking Instructions',
                            recipeInfo: documentData['instructions'],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          const Divider(
                            thickness: 0.3,
                            color: Colors.black54,
                          ),
                            Wrap(
                              children: [

                               Card(
                                    color: kSecondaryColor,
                                    elevation: 5,
                                    shape:  RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35)
                                    ),
                                    child: ListTile(
                                      title: const Text('Edit',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          )),
                                      onTap:(){
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>EditRecipeView(recipeId: documentData['id'],category:documentData['category'], title: documentData['title'], serving: documentData['serving'], cookTime: documentData['cookTime'], instructions: documentData['instructions'], ingredients: documentData['ingredients'],imageUrl: documentData['imageUrl'],)));
                                      } ,
                                    ),
                                  ),
                                // const SizedBox(
                                //   width: 10.0,
                                // ),
                              Card(
                                    color: kDangerColor,
                                    elevation: 5,
                                    shape:  RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(35)
                                    ),
                                    child: ListTile(
                                      title: const Text('Delete',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white,
                                              fontWeight: FontWeight.bold
                                          )),
                                      onTap:(){
                                        showAlertDialog(context,documentData['id'],documentData['title']);
                                      } ,
                                    ),
                                  ),

                              ]
                            )

                        ],
                      ),
                    ),
                  ],
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          )

        ),
      ),
    );
  }
}
