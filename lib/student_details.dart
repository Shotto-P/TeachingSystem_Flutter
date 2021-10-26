import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment4/imageTaken.dart';
import 'package:flutter_assignment4/student.dart';
import 'package:flutter_assignment4/week.dart';
import 'package:flutter_assignment4/week_details.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';

class StudentDetails extends StatefulWidget {
  final String? id;

  const StudentDetails({Key? key, this.id}) : super(key: key);

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {

  final _formKey = GlobalKey<FormState>();
  final studentIdController = TextEditingController();
  final nameController = TextEditingController();
  var imageUrl = "https://upload.wikimedia.org/wikipedia/en/8/8a/The_Lord_of_the_Rings_The_Fellowship_of_the_Ring_%282001%29.jpg";

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    PickedFile image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if(permissionStatus.isGranted){
      image = (await _imagePicker.getImage(source: ImageSource.gallery))!;
      var file = File(image.path);
      if(image != null){
        var snapshot = await _firebaseStorage.ref().child('images/imageName').putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        setState((){
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }
    } else{
      print("Permission not granted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    var student;

    var adding = widget.id == null;
    if(!adding){
      student = Provider.of<StudentModel>(context, listen:false).get(widget.id!);
      studentIdController.text = student!.studentId.toString();
      nameController.text = student.name;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(adding ? "Add Student" : "Edit Student"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if(adding == false)
              Text("Student Index ${widget.id}")
            else
              Text("New Student Here"),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: "Student Id"),
                        controller: studentIdController,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "Name"),
                        controller: nameController,
                      ),
                      Card(
                        child: Container(child:
                          Image.network(imageUrl),
                        ),
                      ),
                      ElevatedButton(
                          onPressed: (){
                            uploadImage();
                          },
                          child: Text("Go to Change Avatar")
                      ),
                      ElevatedButton.icon(onPressed: () {
                        if(_formKey.currentState!.validate()){
                          student = Student(studentId: int.parse(studentIdController.text), name: nameController.text, image: imageUrl, totalScore: 0);
                          if(adding){
                            Provider.of<StudentModel>(context, listen: false).add(student!);
                          }else{
                            Provider.of<StudentModel>(context, listen: false).update(widget.id!, student!);
                          }
                          Navigator.pop(context);
                        }
                      }, icon: Icon(Icons.save), label: Text("Save")),
                      if(adding == false)
                        ElevatedButton(
                            onPressed: () => {Navigator.push(context, MaterialPageRoute(
                                builder: (context) => ChooseWeek(student: student),
                            ))},
                            child: Text("Start Makring")
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

class ChooseWeek extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final Student student;

  ChooseWeek({Key? key, required this.student}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FullScreenText(text: "Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return ChangeNotifierProvider(
            create: (context) => WeekModel(student),
            child: MaterialApp(
              home:Scaffold(
                body: Center(
                  child: WeekContent(),
                ),
              ),
            ),
          );
        }
        return FullScreenText(text: "Loading");
      },
    );
  }
}

class WeekContent extends StatefulWidget{

  @override
  _WeekContentState createState() => _WeekContentState();
}

class _WeekContentState extends State<WeekContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Week"),
      ),
      body: Center(
        child: WeekListContent(),
      ),
    );
  }
}

class WeekListContent extends StatefulWidget{
  @override
  _WeekListContentState createState() => _WeekListContentState();

}

class _WeekListContentState extends State<WeekListContent>{
  @override
  Widget build(BuildContext context) {
    return Consumer<WeekModel>(
        builder: (context, weekModel, _){
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if(weekModel.loading)
                CircularProgressIndicator()
              else Expanded(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    var week = weekModel.items[index];
                    return ListTile(
                        title: Text(week.name),
                        subtitle: Text("Score: " + weekScoreCalculation(week.score!, week.attendence!)),
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text((index+1).toString()),
                        ),
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return WeekDetails(id: week.id!);
                          }));
                        },
                    );
                  },
                  itemCount: weekModel.items.length,
                ),
              )
            ],
          );
        }
    );
  }
}

class FullScreenText extends StatelessWidget{
  final String text;

  const FullScreenText({Key? key, required this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.ltr, child: Column(
        children: [
          Expanded(child: Center(child: Text(text)))
        ]));
  }

}

String weekScoreCalculation(int score, bool attendence){
  int mark1 = score;
  int mark2;
  attendence == true ? mark2 = 100 : mark2 = 0;
  return ((mark1+mark2)/2).toString();
}
