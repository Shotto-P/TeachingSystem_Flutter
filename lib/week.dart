import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment4/student.dart';

class Week {
  String? id;
  int studentId;
  String name;
  String? MarkingScheme;
  String? grade;
  bool? attendence;
  int? score;

  Week({this.id, required this.studentId, required this.name, this.MarkingScheme, this.grade, this.attendence, this.score});
  Week.fromJson(Map<String, dynamic> json):
      studentId = json['studentId'],
      name = json['name'],
      MarkingScheme = json['MarkingScheme'],
      grade = json['grade'],
      attendence = json['attendence'],
      score = json['score'];


  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'name': name,
    'MarkingScheme': MarkingScheme,
    'grade': grade,
    'attendence': attendence,
    'score': score
  };
}

bool? stringTobool(String json){
  if(json == "true")
    return true;
  else
    return false;
}

class WeekModel extends ChangeNotifier {
  final List<Week> items = [];
  final Student student;
  CollectionReference Collection = FirebaseFirestore.instance.collection('students');
  bool loading = false;
  WeekModel(this.student){
    Collection = Collection.doc(this.student.id).collection('week');
    print(Collection);
    var snapshot = Collection.doc("Week 01");
    if(snapshot.get()=={}) {
      Collection.doc("Week 01").set({
        'studentId': this.student.studentId,
        'name': "Week 01",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 02").set({
        'studentId': this.student.studentId,
        'name': "Week 02",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 03").set({
        'studentId': this.student.studentId,
        'name': "Week 03",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 04").set({
        'studentId': this.student.studentId,
        'name': "Week 04",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 05").set({
        'studentId': this.student.studentId,
        'name': "Week 05",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 06").set({
        'studentId': this.student.studentId,
        'name': "Week 06",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 07").set({
        'studentId': this.student.studentId,
        'name': "Week 07",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 08").set({
        'studentId': this.student.studentId,
        'name': "Week 08",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 09").set({
        'studentId': this.student.studentId,
        'name': "Week 09",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 10").set({
        'studentId': this.student.studentId,
        'name': "Week 10",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 11").set({
        'studentId': this.student.studentId,
        'name': "Week 11",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
      Collection.doc("Week 12").set({
        'studentId': this.student.studentId,
        'name': "Week 12",
        'MarkingScheme': "Not Selected",
        'grade': "Not Selected",
        'attendence': false,
        'score': 0
      });
    }
    fetch();
  }

  void update(String id, Week item) async{
    loading = true;
    notifyListeners();
    await Collection.doc(id).set(item.toJson());
    fetch();
  }

  void fetch() async{
    items.clear();
    loading = true;
    notifyListeners();
    int totalWeeklyScore = 0;
    var querySnapshot = await Collection.orderBy("name").get();

    querySnapshot.docs.forEach((doc) {
      print(doc.data());
      Map<String, dynamic> data = {
        'studentId': doc["studentId"],
        'name': doc["name"],
        'MarkingScheme': doc["MarkingScheme"],
        'grade': doc["grade"],
        'attendence': doc["attendence"],
        'score': doc["score"]
      };
      var week = Week.fromJson(data);
      print(week);
      week.id = week.name;
      items.add(week);
      //totalWeeklyScore = totalWeeklyScore + int.parse(weekScoreCalculation(week.score!, week.attendence!));
      print(items);
    });
    await Future.delayed(Duration(seconds: 2));
    loading = false;
    //this.student.totalScore = totalWeeklyScore/12;
    notifyListeners();
  }

  Week? get(String id){
    if(id == null) return null;
    return items.firstWhere((week) => week.id == id);
  }
}

String weekScoreCalculation(int score, bool attendence){
  int mark1 = score;
  int mark2;
  attendence == true ? mark2 = 100 : mark2 = 0;
  return ((mark1+mark2)/2).toString();
}