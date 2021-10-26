import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Student {
  String? id;
  int studentId;
  String name;
  double? totalScore;
  String? image;

  Student({this.id, required this.studentId, required this.name, this.totalScore, this.image});
  Student.fromJson(Map<String, dynamic> json):
      studentId = json['studentId'],
      name = json['name'],
      totalScore = json['totalScore'],
      image = json['image'];

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'name': name,
    'totalScore': totalScore,
    'image': image
  };
}

class StudentModel extends ChangeNotifier {
  final List<Student> items = [];
  CollectionReference studentsCollection = FirebaseFirestore.instance.collection('students');
  bool loading = false;
  StudentModel() {
    fetch();
  }

  void add(Student item) async{
    loading = true;
    notifyListeners();
    await studentsCollection.doc(item.studentId.toString()).set(item.toJson());
    fetch();
  }

  void update(String id, Student item) async{
    loading = true;
    notifyListeners();
    await studentsCollection.doc(id).set(item.toJson());
    fetch();
  }

  void delete(String id) async{
    loading = true;
    notifyListeners();
    await studentsCollection.doc(id).delete();
    fetch();
  }

  void removeAll(){
    items.clear();
    notifyListeners();
  }

  void fetch() async{
    items.clear();
    loading = true;
    notifyListeners();
    var querySnapshot = await studentsCollection.orderBy("name").get();

    querySnapshot.docs.forEach((doc) {
      print(doc.data());
      Map<String, dynamic> data = {
        'studentId': doc["studentId"],
        'name': doc["name"],
        'totalScore': doc["totalScore"],
        'image': doc["image"]
      };
      var student = Student.fromJson(data);
      print(student);
      student.id = student.studentId.toString();
      items.add(student);
      print(items);
    });
    await Future.delayed(Duration(seconds: 2));
    loading = false;
    notifyListeners();
  }

  Student? get(String id){
    if(id == null) return null;
    return items.firstWhere((student) => student.id == id);
  }


}
