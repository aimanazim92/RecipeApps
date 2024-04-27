class UserModel {
  String? uid;
  String? email;
  String? phone;
  String? name;

  UserModel({this.uid,this.email,this.phone,this.name});

  //receive data from server
  factory UserModel.fromMap(map){
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      phone: map['phone'],
      name: map['name'],
    );
  }
  //sending data to server
  Map<String,dynamic> toMap(){
    return{
      'uid': uid,
      'email': email,
      'phone': phone,
      'name': name,
    };
  }




}