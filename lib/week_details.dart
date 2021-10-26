import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment4/main.dart';
import 'package:flutter_assignment4/student.dart';
import 'package:flutter_assignment4/week.dart';
import 'package:provider/provider.dart';
import 'package:select_form_field/select_form_field.dart';

class WeekDetails extends StatefulWidget {
  final String? id;

  const WeekDetails({Key? key, this.id}) : super(key: key);

  @override
  _WeekDetailsState createState() => _WeekDetailsState();
}

class _WeekDetailsState extends State<WeekDetails> {

  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _markingScheme = [
    {
      'value': 'Score out of 100',
      'label': 'Score out of 100',
    },
    {
      'value': 'HD/DN/CR/PP/NN',
      'label': 'HD/DN/CR/PP/NN',
    },
    {
      'value': 'A/B/C/D/F',
      'label': 'A/B/C/D/F',
    },
  ];
  final List<Map<String, dynamic>> _HDGrade = [
    {
      'value': '100',
      'label': 'HD+',
    },
    {
      'value': '80',
      'label': 'HD',
    },
    {
      'value': '70',
      'label': 'DN',
    },
    {
      'value': '60',
      'label': 'CR',
    },
    {
      'value': '50',
      'label': 'PP',
    },
    {
      'value': '0',
      'label': 'NN',
    },
  ];
  final List<Map<String, dynamic>> _AGrade = [
    {
      'value': '100',
      'label': 'A',
    },
    {
      'value': '80',
      'label': 'B',
    },
    {
      'value': '70',
      'label': 'C',
    },
    {
      'value': '60',
      'label': 'D',
    },
    {
      'value': '0',
      'label': 'F',
    },
  ];
  final scoreController = TextEditingController();
  final nameController = TextEditingController();
  final studentIdController = TextEditingController();
  final markingSchemeController = TextEditingController();
  final gradeController = TextEditingController();
  String valueChanged =  "";
  String? valueSaved = "";
  bool? attended = false;
  String? gradeSaved = "";
  int score = 0;
  int n = 0;

  @override
  Widget build(BuildContext context) {
    var week;

    week = Provider.of<WeekModel>(context, listen:false).get(widget.id!);
    studentIdController.text = week.studentId.toString();
    nameController.text = week.name;
    if(week.MarkingScheme != "Not Selected" && n == 0){
      markingSchemeController.text = week.MarkingScheme;
      valueChanged = week.MarkingScheme;
      gradeController.text = week.grade;
      scoreController.text = week.score.toString();
      attended = week.attendence;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Marking"),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text("Week Index ${widget.id}"),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "Student Id"),
                      controller: studentIdController,
                      enabled: false,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Week"),
                      controller: nameController,
                      enabled: false,
                    ),
                    SelectFormField(
                      controller: markingSchemeController,
                      type: SelectFormFieldType.dropdown,
                      icon: Icon(Icons.format_shapes),
                      labelText: 'Marking Scheme',
                      items: _markingScheme,
                      onChanged: (String val) {
                        setState(() {
                          valueChanged = val;
                          n++;
                        });
                      },
                      onSaved: (String? val) {
                        this.valueChanged = val!;
                      },
                    ),
                    if(this.valueChanged == "Score out of 100")
                      TextFormField(
                        decoration: InputDecoration(labelText: "Score"),
                        controller: scoreController,
                      ),
                    if(this.valueChanged == "HD/DN/CR/PP/NN")
                      SelectFormField(
                        controller: gradeController,
                        type: SelectFormFieldType.dropdown,
                        icon: Icon(Icons.format_shapes),
                        labelText: 'Grade',
                        items: _HDGrade,
                        onChanged: (String val) {
                          this.gradeSaved = val;
                          this.score = int.parse(val);
                          print(this.score);
                          n++;
                        },
                        onSaved: (String? val) {
                          this.gradeSaved = val;
                          this.score = int.parse(val!);
                          print(this.score);
                        },
                      ),
                    if(this.valueChanged == "A/B/C/D/F")
                      SelectFormField(
                        controller: gradeController,
                        type: SelectFormFieldType.dropdown,
                        icon: Icon(Icons.format_shapes),
                        labelText: 'Grade',
                        items: _AGrade,
                        onChanged: (String val) {
                          setState(() {
                            this.gradeSaved = val;
                            this.score = int.parse(val);
                            print(this.score);
                            n++;
                          });
                        },
                        onSaved: (String? val) {
                          this.gradeSaved = val;
                          this.score = int.parse(val!);
                        },
                      ),
                    CheckboxListTile(
                      secondary: const Icon(Icons.alarm),
                      title: const Text("Attended"),
                      value: attended,
                      onChanged: (bool? value){
                        setState(() {
                          this.attended = value;
                        });
                      },
                    ),
                    ElevatedButton.icon(onPressed: () {
                      if(_formKey.currentState!.validate()){
                        print("TEST!!!!!!!!!!!!: "+scoreController.text);
                        if(scoreController.text != "0"){
                          score = int.parse(scoreController.text);
                        }
                        print(this.score);
                        week = Week(studentId: int.parse(studentIdController.text), name: nameController.text, MarkingScheme: valueChanged, grade: gradeSaved, score: score, attendence: attended,);
                        Provider.of<WeekModel>(context, listen: false).update(widget.id!, week!);

                        Navigator.pop(context);
                      }
                    }, icon: Icon(Icons.save), label: Text("Save")),

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