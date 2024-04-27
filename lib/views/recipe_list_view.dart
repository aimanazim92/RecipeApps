import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:filter_list/filter_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:untitled/components/recipe_card.dart';
import 'package:untitled/models/category.dart';
import 'package:untitled/views/recipe_detail_view.dart';
import '../components/color.dart';
import '../models/recipe.dart';
import '../models/user.dart';
import 'create_recipe_view.dart';

class RecipeListView extends StatefulWidget {


  RecipeListView({super.key});

  @override
  _RecipeListViewState createState() => _RecipeListViewState();

}

class _RecipeListViewState extends State<RecipeListView>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  UserModel loggedInUser = UserModel();
  late List<String> item = [];
  String userID = FirebaseAuth.instance.currentUser!.uid;
  bool filter = false;
  List<String> query = [];
  List<CategoryRecipe> selectedList =[];
  List<CategoryRecipe> categorylist=[
    CategoryRecipe(name: "Appertizers"),
    CategoryRecipe(name: "Main Course"),
    CategoryRecipe(name: "Side Dishes"),
    CategoryRecipe(name: "Beverages"),
    CategoryRecipe(name: "Snacks"),
    CategoryRecipe(name: "Soups & Stews"),
    CategoryRecipe(name: "Bakery Items"),
    CategoryRecipe(name: "Malay Cuisines"),
    CategoryRecipe(name: "Indian Cuisines"),
    CategoryRecipe(name: "Chinese Cuisines"),
  ];

  late CollectionReference ref = FirebaseFirestore.instance.collection('recipes');
  


  @override
  void initState(){
    super.initState();

    FirebaseFirestore.instance.collection('users').doc(userID).get().then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  void openFilterDialog() async {
    await FilterListDialog.display<CategoryRecipe>(
      context,
      listData: categorylist,
      selectedListData: selectedList,
      choiceChipLabel: (category) => category!.name,
      validateSelectedItem: (list, val) => list!.contains(val),
      onItemSearch: (category, query) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      },
      onApplyButtonClick: (list) {
        setState(() {
          selectedList = List.from(list!);
          List<String> categoryNames = selectedList.map((category) => category.name).toList();
          // Use categoryNames directly in whereIn clause
          query = categoryNames;
          log('Query: $query');
          filter = selectedList.isNotEmpty;
        });
        Navigator.pop(context);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    log("in build $query");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Recipes'),
        backgroundColor: kSecondaryColor,
        foregroundColor: kTextLightColor,
      ),
      floatingActionButton:
      Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 20,
            right:25,
            child: IconButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterRecipe(),
                ),
              );
              }, icon: const Icon(CupertinoIcons.plus_circle_fill,color: kSecondaryColor, size: 45,),),
          ),
          Positioned(bottom:80,right:25,child: IconButton(icon: const Icon(Icons.filter_alt,color: kSecondaryColor,size:45), onPressed: () { openFilterDialog(); },)),
        ],
      ),
      body: filter
          ?  StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('category', whereIn: query).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasError){
            return Center(child: Text("Error: ${snapshot.error}"),);
          }
          if(snapshot.hasData){
            return Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  child:
                  ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index){
                      final DocumentSnapshot documentSnapshot =
                      (snapshot.data!.docs[index]);
                      return  RecipeCard(
                        title: documentSnapshot['title'],
                        cookTime: documentSnapshot['cookTime'],
                        thumbnailUrl: documentSnapshot['imageUrl'],
                        recipeId: documentSnapshot['id'],
                      );
                    },
                  ),
                )
              ],
            );

          }
          return const Center(child: CircularProgressIndicator(),);
        },
      )
          :  StreamBuilder(
        stream: ref.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.hasError){
            return Center(child: Text("Error: ${snapshot.error}"),);
          }
          if(snapshot.hasData){
            return Flex(
              direction: Axis.vertical,
              children: [
                Flexible(
                  child:
                  ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index){
                      final DocumentSnapshot documentSnapshot =
                      (snapshot.data!.docs[index]);
                      return  RecipeCard(
                        title: documentSnapshot['title'],
                        cookTime: documentSnapshot['cookTime'],
                        thumbnailUrl: documentSnapshot['imageUrl'],
                        recipeId: documentSnapshot['id'],
                      );
                    },
                  ),
                )
              ],
            );

          }
          return const Center(child: CircularProgressIndicator(),);
        },
      )


    );
  }
}



