import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_assignment4/student.dart';
import 'package:flutter_assignment4/student_details.dart';
import 'package:provider/provider.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MyApp()
  );
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return AppBasic();
  }

}

class WelcomeContent extends StatefulWidget{

  @override
  _WelcomeContentState createState() => _WelcomeContentState();
}

class _WelcomeContentState extends State<WelcomeContent> {
  String title = "Marking System";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Content(result: title),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Course",
        child: Icon(Icons.add),
        onPressed: () => _DynamicFloatingButton(context),
      ),
    );
  }

  void _DynamicFloatingButton(BuildContext context) {
    if(title == "Marking System"){
      _awaitReturnValueFromSecondPage(context);
    }else{
      showDialog(context: context, builder: (context){
        return StudentDetails();
      });
    }
  }

  void _awaitReturnValueFromSecondPage(BuildContext context) async {
    final result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => AddCoursePage(),
    ));
    setState((){
      title = result;
    });
  }
}

class Content extends StatelessWidget{
  final String result;

  const Content({Key? key, required this.result}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return result=="Marking System" ? Text("Welcome to Marking System",
      style: Theme.of(context).textTheme.headline6,) : StudentListContent();
  }

}



class AppBasic extends StatelessWidget{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
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
              create: (context) => StudentModel(),
              child: MaterialApp(
                home:Scaffold(
                  body: Center(
                    child: WelcomeContent(),
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

class StudentListContent extends StatefulWidget{
  @override
  _StudentListContentState createState() => _StudentListContentState();

}

class _StudentListContentState extends State<StudentListContent>{
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentModel>(
      builder: (context, studentModel, _){
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("There are " + studentModel.items.length.toString() + " students"),
            if(studentModel.loading)
              CircularProgressIndicator()
            else Expanded(
              child: ListView.builder(
                  itemBuilder: (_, index) {
                    var student = studentModel.items[index];
                    return Dismissible(
                        background: Container(color: Colors.blue),
                        key: ValueKey<Student>(studentModel.items[index]),
                        child: ListTile(
                          title: Text(student.name),
                          subtitle: Text(student.studentId.toString() + "  Total Score: "+student.totalScore.toString()),
                          leading: student.image != null ? Image.network(student.image!) : null,
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return StudentDetails(id: student.id!);
                            }));
                          },
                        ),
                        onDismissed: (DismissDirection direction){
                          setState(() {
                            studentModel.delete(student.id!);
                          });
                        },
                    );
                  },
                  itemCount: studentModel.items.length,
              ),
            )
          ],
        );
      }
    );
  }
}

class AddCoursePage extends StatefulWidget{
  @override
  _AddCoursePageState createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  var txtNameController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Course"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Expanded(
                child: TextField(
                  controller: txtNameController,
                  decoration: InputDecoration(
                    hintText: "Enter the course name",
                    labelText: "Course"
                  ),
                )
            ),
            ElevatedButton(
                onPressed: () => {Navigator.pop(context, txtNameController.text)},
                child: Text("Confirm")
            ),
          ],
        ),
      ),
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