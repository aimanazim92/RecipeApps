import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../components/color.dart';
import 'dart:io';

import '../models/recipe.dart';
class EditRecipeView extends StatefulWidget {
  final String recipeId, category,title,imageUrl;
  final int serving,cookTime;
  final List<dynamic> instructions,ingredients;
  EditRecipeView({super.key, required this.recipeId,required this.category, required this.title, required this.serving, required this.cookTime, required this.instructions, required this.ingredients, required this.imageUrl});
  @override
  _EditRecipeViewState createState() => _EditRecipeViewState();

}

class _EditRecipeViewState extends State<EditRecipeView>{

  var categoryList = ['Appertizers','Main Course','Side Dishes','Beverages','Snacks',"Soups & Stews",'Bakery Items','Malay Cuisines','Chinese Cuisines',"Indian Cuisines"];
  late String dropdownvalue;
  late String title,imageUrl_c;
  late int cookTime,serving;
  late List<dynamic> instructions, ingredients;
  String? titleError, categoryError, imageURLError,cookTimeError,servingError;
  late List<XFile> file;
  late TextEditingController controllerTitle, controllerServing, controllerCookTime ;

  List<XFile> _selectedFiles = [];
  List<String> _arrImageUrl = [];
  List<String> ImagePath = [];
  FirebaseStorage storage = FirebaseStorage.instance;
  UploadTask? task;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log(widget.recipeId);
    title = widget.title;
    serving = widget.serving;
    cookTime = widget.cookTime;
    instructions = widget.instructions;
    ingredients = widget.ingredients;
    dropdownvalue = widget.category;
    imageUrl_c = widget.imageUrl;

    controllerTitle = TextEditingController(text: widget.title);
    controllerServing = TextEditingController(text: widget.serving.toString());
    controllerCookTime = TextEditingController(text: widget.cookTime.toString());

    titleError = null;
    categoryError = null;
    imageURLError = null;
    cookTimeError = null;
    servingError = null;
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

    if (imageUrl_c.isEmpty) {
      if(_selectedFiles.isEmpty){
        Fluttertoast.showToast(msg: "Please insert the image");
        isValid = false;
      }

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

  Widget buildGridView(List<XFile> selectedFiles,String imageUrl){
    if(imageUrl_c.isNotEmpty){
      return GridView(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
                height: 10,
                width: 10,
              ),
            ),
          ],


      );
     }
    // else {
    //   return Container(color: Colors.white);
    // }
    else if (_selectedFiles.isNotEmpty) {
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

  Future updateRecipe(Recipe recipe, List<String> images)async {
    try{
      // final docProduct = FirebaseFirestore.instance.collection('recipes').doc();
      // recipe.id = docProduct.id;
      // recipe.serving = serving;
      // recipe.ingredients = ingredients;
      // recipe.instructions = instructions;
      // recipe.cookTime = cookTime;
      // recipe.category = dropdownvalue;
      // recipe.title = title;
      // log("IN  createRecipe");
      // final json = recipe.toJson();
      // await docProduct.set(json);
      if(imageUrl_c.isEmpty){
        await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId).update({"category":dropdownvalue,"cookTime":cookTime,"imageUrl":images[0].toString(),'ingredients':ingredients,"instructions":instructions,"serving":serving,"title":title});
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Recipe Created Successfully");
      }
      else if(imageUrl_c.isNotEmpty){
        await FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId)
            .update({"category":dropdownvalue,"cookTime":cookTime,"imageUrl":imageUrl_c,'ingredients':ingredients,"instructions":instructions,"serving":serving,"title":controllerTitle.text});
        Navigator.pop(context);
        Fluttertoast.showToast(msg: "Recipe Created Successfully");
      }


    }catch (e) {
      if (e is FirebaseException) {
        print('Firebase Error: ${e.message}');
        log('Firebase Error: ${e.message}');
        Fluttertoast.showToast(msg: "The error is${e.message}/${e.code}");
        // Handle specific Firebase errors here, such as permission denied, network issues, etc.
      } else {
        print('Unexpected error: $e');
        log('Unexpected error: $e');
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
        title: const Text('Edit Recipe'),
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
              controller: controllerTitle,
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
              controller: controllerServing,
              decoration:  const InputDecoration(
                // errorText: servingError,
                labelText: "How many serving",
                border: OutlineInputBorder(),
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
              controller: controllerCookTime,
              decoration:  const InputDecoration(
                // errorText: cookTimeError,
                labelText: "Time Taken to finish (min)",
                border: OutlineInputBorder(),
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
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: instructions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Intruction ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: instructions[index]),
                          onChanged: (value) {
                            instructions[index] = value;
                          },
                        ),
                        SizedBox(height: screenHeight * .025),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                foregroundColor: kTextLightColor
                ),
                  onPressed: () {
                    // Add a new item to the data list
                    setState(() {
                      instructions.add("");
                    });
                  },
                  child: Text('Add Instructions'),
                ),
              ],
            ),
            SizedBox(height: screenHeight * .040),
            const Text('Ingredient',style: TextStyle(
                color: kTextColor,
                fontSize: 17,
                fontWeight: FontWeight.w800
            ),),
            SizedBox(height: screenHeight * .025),
            Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: ingredients.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Intruction ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          controller: TextEditingController(text: ingredients[index]),
                          onChanged: (value) {
                            ingredients[index] = value;
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,

                        ),
                        SizedBox(height: screenHeight * .025),
                      ],
                    );
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kTextLightColor
                  ),
                  onPressed: () {
                    // Add a new item to the data list
                    setState(() {
                      ingredients.add("");
                    });
                  },
                  child: const Text('Add Ingredients'),
                ),
              ],
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
                  child: Text(imageUrl_c.isEmpty
                      ? fName
                      : "",
                      style: const TextStyle(
                      color: kTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w800
                  )),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: imageUrl_c.isEmpty
                      ?  ElevatedButton(style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kTextLightColor
                  ),onPressed: selectImage,
                         child: const Text('Select Image',textAlign: TextAlign.center,),

                  )
                      :  ElevatedButton(style: ElevatedButton.styleFrom(
                      backgroundColor: kSecondaryColor,
                      foregroundColor: kTextLightColor
                  ),onPressed: (){
                        setState(() {
                          imageUrl_c = "";
                        });
                  },
                    child: const Text('Delete Image',textAlign: TextAlign.center,),

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
              child: buildGridView(_selectedFiles,imageUrl_c),
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
                    if(imageUrl_c.isEmpty){
                      log("IN condition image_c empty");
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
                       updateRecipe(recipe,_arrImageUrl);

                    }
                    else if(imageUrl_c.isNotEmpty){
                      log("IN condition image_c is exist");
                      final recipe = Recipe(
                          title: title,
                          ingredients: ingredients,
                          instructions: instructions,
                          imageUrl: "",
                          serving: serving,
                          category: dropdownvalue,
                          cookTime: cookTime

                      );
                      // await uploadFunction(_selectedFiles);
                       updateRecipe(recipe,_arrImageUrl);
                    }


                  }

                },
                child: Text('Update Recipe')),
            SizedBox(
                height: screenHeight * .125),


          ],
        ),
      ),

    );
  }
}