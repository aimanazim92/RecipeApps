import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../components/color.dart';
import '../components/field_text.dart';
import '../components/form_button.dart';
import '../models/recipe.dart';

class RegisterRecipe extends StatefulWidget {

  const RegisterRecipe({ super.key});

  @override
  _RegisterRecipeState createState() => _RegisterRecipeState();
}

class _RegisterRecipeState extends State<RegisterRecipe> {
  var categoryList = ['Appertizers','Main Course','Side Dishes','Beverages','Snacks',"Soups & Stews",'Bakery Items','Malay Cuisines','Chinese Cuisines',"Indian Cuisines"];
  String dropdownvalue = 'Appertizers';
  final auth = FirebaseAuth.instance;
  bool _isHidden = true;
  late String title, category;
  late int serving, cookTime;
  late List<String> ingredients, instructions, imageURL;
  String? titleError, categoryError, imageURLError,cookTimeError,servingError;
  UploadTask? task;
  int count= 1;
  late List<XFile> file;
  List<XFile> _selectedFiles = [];
  List<String> _arrImageUrl = [];
  List<String> ImagePath = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  late TextEditingController instructionItem;
  late TextEditingController ingredientItem;

  @override
  void initState() {
    super.initState();
    title = "";
    category = "";
    instructionItem = TextEditingController();
    ingredientItem = TextEditingController();
    serving = 0;
    cookTime = 0;
    imageURL = [];
    ingredients = [];
    instructions = [];

    titleError = null;
    categoryError = null;
    imageURLError = null;
    cookTimeError = null;
    servingError = null;
  }

  @override
  void dispose(){
    instructionItem.dispose();
    ingredientItem.dispose();

    super.dispose();
  }

  void resetErrorText() {
    setState(() {
      titleError = null;
      categoryError = null;
      imageURLError = null;
      cookTimeError = null;
      servingError = null;
    });
  }

  bool validate() {
    resetErrorText();
    bool isValid = true;
    if (title.isEmpty) {
      setState(() {
        titleError = "Please insert your title";
      });
      isValid = false;
    }

    if (dropdownvalue.isEmpty) {
      setState(() {
        categoryError = "Please insert your category";
      });
      isValid = false;
    }

    if (_selectedFiles.isEmpty) {
      Fluttertoast.showToast(msg: "Please insert the image");
      isValid = false;
    }
    if (cookTime == 0) {
      setState(() {
        cookTimeError = "Please insert the time taken needed";
      });
      isValid = false;

    }if (serving == 0) {
      setState(() {
        servingError = "Please insert the serving";
      });
      isValid = false;
    }
    if (instructions.isEmpty) {
      Fluttertoast.showToast(msg: "Please insert instruction");
      isValid = false;
    }
    if (ingredients.isEmpty) {
      Fluttertoast.showToast(msg: "Please insert ingredients");
      isValid = false;
    }
    log("Validation Result $isValid");
    log("title: $title , category: $dropdownvalue , iamgeURL: ${_selectedFiles.toList()},cooktIme: $cookTime , serving: $serving , instruction: $instructions , ingredients: $ingredients");
    return isValid;
  }

  Widget buildGridView(List<XFile> selectedFiles){
    if (_selectedFiles.isNotEmpty) {
      return GridView.builder(
          shrinkWrap: true,
          itemCount: _selectedFiles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.file(
                File(_selectedFiles[index].path),
                fit: BoxFit.cover,
                height: 10,
                width: 10,
              ),
            );
          }
      );
    } else {
      return Container(color: Colors.white);
    }
  }
  Future<void> selectImage() async {
    if (_selectedFiles.isNotEmpty) {
      _selectedFiles.clear();
    }
    try {
      final XFile? result = await ImagePicker().pickImage(
        maxWidth: 1800,
        maxHeight: 1800, source: ImageSource.gallery,
      );
      if (result == null) {
        Fluttertoast.showToast(msg: "No Image Selected From Gallery");
        return;
      }
      _selectedFiles.add(result);
    } catch (e) {
      print("Something went wrong: $e");
    }
    setState(() {
      // Update UI if needed
    });
  }

  Future _fromCamera() async {
    final XFile? photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,);
    if (photo == null){
      Fluttertoast.showToast(msg: "No Picture Taken");
      return;
    }
    _selectedFiles.add(photo);
    // setState(() => file = File(photo.path) );
  }

  Future uploadFunction(List<XFile> _images) async{

    for(int i = 0; i< _images.length; i++){
      var imageUrl = await uploadFile(_images[i]);
      _arrImageUrl.add(imageUrl.toString());
      log("Photo: ${imageUrl.toString()}");
    }

    log("upload Photo");
  }

  Future<String> uploadFile(XFile _image) async{

    Reference reference = storage.ref('recipes').child(_image.name);
    UploadTask uploadTask = reference.putFile(File(_image.path));
    await uploadTask.whenComplete(() async {
      await reference.getDownloadURL();
      print(reference.getDownloadURL());
    } );
    log("upload File");
    return await reference.getDownloadURL();
  }

  Future<void> openDialogInstruction() => showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Enter your instruction, Step ${instructions.length + 1}"),
            content: TextField(
              autofocus: true,
              controller: instructionItem,
              decoration: const InputDecoration(
                labelText: "Instruction",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    instructions.add(instructionItem.text);
                    instructionItem.clear();
                  });
                  log("list of instruction $instructions");
                },
                child: Text("Next Step"),
              ),
              TextButton(
                onPressed: () {
                  instructionItem.clear();
                  Navigator.of(context).pop();
                  log("list of instruction $instructions");
                },
                child: Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );


  Future<void> openDialogIngredient() => showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Enter your ingredients, Ingredients ${ingredients.length + 1}"),
            content: TextField(
              autofocus: true,
              controller: ingredientItem,
              decoration: const InputDecoration(
                labelText: "Instruction",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              minLines: 1,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    ingredients.add(ingredientItem.text);
                    ingredientItem.clear();
                  });
                  log("list of ingredients $ingredients");
                },
                child: Text("Next Ingredients"),
              ),
              TextButton(
                onPressed: () {
                  ingredientItem.clear();
                  Navigator.of(context).pop();
                  log("list of instruction $ingredients");
                },
                child: Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );

  Future createRecipe(Recipe recipe, List<String> images)async {
    try{
      final docProduct = FirebaseFirestore.instance.collection('recipes').doc();
      recipe.id = docProduct.id;
      recipe.serving = serving;
      recipe.ingredients = ingredients;
      recipe.instructions = instructions;
      recipe.cookTime = cookTime;
      recipe.category = dropdownvalue;
      recipe.title = title;
      log("IN  createRecipe");
      final json = recipe.toJson();
      await docProduct.set(json);


      FirebaseFirestore.instance.collection('recipes').doc(docProduct.id).update({"imageUrl":images[0].toString()});
    }catch (e) {
      if (e is FirebaseException) {
        print('Firebase Error: ${e.message}');
        Fluttertoast.showToast(msg: "The error is${e.message}/${e.code}");
        // Handle specific Firebase errors here, such as permission denied, network issues, etc.
      } else {
        print('Unexpected error: $e');
        Fluttertoast.showToast(msg: "The error is${e.toString()}");
        // Handle other types of errors, such as network issues, unexpected exceptions, etc.
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    final fName = _selectedFiles.isNotEmpty ? 'Images Selected '+ _selectedFiles.length.toString() : 'No Image Selected';

    for(int i =0; i<_selectedFiles.length;i++){
      ImagePath.add(_selectedFiles[i].name);
    }
    double screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Recipe'),
        backgroundColor: kSecondaryColor,
        foregroundColor: kTextLightColor,
      ),
      body: Padding(
        padding:EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          shrinkWrap: true,
          children: [

            SizedBox(height: screenHeight * .01),
            const Text(
              "Enter your recipe details",
                style: TextStyle(
                    color: kTextColor,
                    fontSize: 25,
                    fontWeight: FontWeight.w800
                )
            ),
            SizedBox(height: screenHeight * .045),
            TextField(
              onChanged: (value){
                setState(() {
                  title = value;
                });
              },
              decoration: InputDecoration(
                errorText: titleError,
                labelText: "Recipe Name",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: screenHeight * .025),

            DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                value: dropdownvalue,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: categoryList.map((String items) {
                  return DropdownMenuItem(
                    value: items,
                    child: Text(items),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownvalue = newValue!;
                  });
                }
            ),


            SizedBox(height: screenHeight * .025),
            TextField(
              onChanged: (value){
                setState(() {
                  serving =  int.parse(value);
                });
              },
              decoration:  InputDecoration(
                errorText: servingError,
                labelText: "How many serving",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,

            ),
            SizedBox(height: screenHeight * .025),
            TextField(
              onChanged: (value){
                setState(() {
                  cookTime =  int.parse(value);
                });
              },
              decoration:  InputDecoration(
                errorText: cookTimeError,
                labelText: "Time Taken to finish (min)",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,

            ),
            SizedBox(height: screenHeight * .040),
            const Text('Instruction',style: TextStyle(
              color: kTextColor,
              fontSize: 17,
              fontWeight: FontWeight.w800
            ),),
            SizedBox(height: screenHeight * .025),
            ElevatedButton(onPressed: (){

              openDialogInstruction();
            }, child: Text("Add Instruction")
            ,style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                foregroundColor: kTextLightColor
              ),
            ),
            SizedBox(height: screenHeight * .040),
            const Text('Ingredient',style: TextStyle(
                color: kTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w800
            ),),
            SizedBox(height: screenHeight * .025),
            ElevatedButton(onPressed: (){
              openDialogIngredient();
            }, child: Text("Add Ingredient")
              ,style: ElevatedButton.styleFrom(
                  backgroundColor: kSecondaryColor,
                  foregroundColor: kTextLightColor
              ),
            ),
            SizedBox(height: screenHeight * .040),
            const Text('Picture',style: TextStyle(
                color: kTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w800
            )),
            SizedBox(height: screenHeight * .025),
            Row(
              children: [
                Expanded(
                  child: Text(fName,style: const TextStyle(
                      color: kTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800
                  )),
                ),
                const SizedBox(width: 5),
                Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    foregroundColor: kTextLightColor
                ),onPressed: selectImage,
                  child: const Text('Select Image',textAlign: TextAlign.center,),

                ),
                ),
                const SizedBox(width: 5),
                // Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(
                //     backgroundColor: kSecondaryColor,
                //     foregroundColor: kTextLightColor
                // ),onPressed: _fromCamera,
                //     child: const Text('Take Photo')
                // ),
                // )
              ],
            ),
            const SizedBox(width: 5),
            Container(
              child: buildGridView(_selectedFiles),
            ),
            SizedBox(height: screenHeight * .075),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: kSecondaryColor,
                    foregroundColor: kTextLightColor
                ),
                onPressed: ()async{
                  if(validate()){
                    log("PASS THE VALIDATION");
                    log("HEREIS ${ImagePath[0].toString()}");

                      final recipe = Recipe(
                          title: title,
                          ingredients: ingredients,
                          instructions: instructions,
                          imageUrl: "",
                          serving: serving,
                          category: dropdownvalue,
                          cookTime: cookTime

                      );
                       await uploadFunction(_selectedFiles);
                      createRecipe(recipe,_arrImageUrl);

                      Navigator.pop(context);
                      Fluttertoast.showToast(msg: "Recipe Created Successfully");

                  }

                },
                child: Text('Create Recipe')),
            SizedBox(
                height: screenHeight * .125),


          ],
        ),
      ),

    );
  }
}
