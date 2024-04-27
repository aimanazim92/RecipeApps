class Recipe {
   String? title,id;
   List<dynamic>? ingredients;
   List<dynamic>? instructions;
   String? category;
   int? serving;
   int? cookTime;
   String? imageUrl;


  Recipe({
    this.id,
     this.title,
     this.ingredients,
     this.category,
     this.cookTime,
     this.imageUrl,
      this.serving,
     this.instructions,
  });

  factory Recipe.fromMap(map){
    return Recipe(
      id: map['id'],
      title: map['title'],
      ingredients: map['ingredients'],
      category: map['category'],
      cookTime: map['cookTime'],
      imageUrl: map['imageUrl'],
      serving: map['serving'],
      instructions: map['instructions'],
    );
  }

   Map<String,dynamic> toMap(){
     return{
       'id': id,
       'title': title,
       'ingredients': ingredients,
       'category': category,
       'cookTime': cookTime,
       'imageUrl': imageUrl,
       'serving': serving,
       'instructions': instructions,

     };
   }

   Map<String, dynamic> toJson() =>{
     'id': id,
     'title': title,
     'ingredients': ingredients,
     'category': category,
     'cookTime': cookTime,
     'imageUrl': imageUrl,
     'serving': serving,
     'instructions': instructions,
   };


   static Recipe fromJson(Map<String, dynamic> json) => Recipe(
     id: json['id'],
     title: json['title'],
     ingredients: json['ingredients'],
     category: json['category'],
     cookTime: json['cookTime'],
     imageUrl: json['imageUrl'],
     serving: json['serving'],
     instructions: json['instructions'],
   );

}
