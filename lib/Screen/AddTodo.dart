import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddTodo extends StatefulWidget {
  final Map? todo;
  const AddTodo(
      {super.key,
      this.todo,
      }
      );


  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  TextEditingController titleController=TextEditingController();
  TextEditingController descriptionController=TextEditingController();
  bool isEdit=false;
  @override
  void initState() {
    super.initState();
    final todo=widget.todo;
    if(todo!=null){
      isEdit=true;
      final title =todo['title'];
      final description =todo['description'];
      titleController.text=title;
      descriptionController.text=description;
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ?'Edit a Task':"Add a Task"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/MainBackground.jpg'),
                fit: BoxFit.cover
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height*0.1,),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Title",

                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Description",
                  hoverColor: Colors.green,


                ),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 8,
              ),
              SizedBox(height: size.height*0.02,),
              TextButton(

                  style: TextButton.styleFrom(backgroundColor: Colors.lime,),
                  onPressed: isEdit?updateData:submitData,
                  child: Container(
                      width: size.width*0.5,
                      height: size.height*0.03,
                      child: Text(isEdit? "Update":"Submit",textAlign:TextAlign.center,)))
            ],
          ),
        ),
      ),
    );
  }
  Future<void> updateData()async {
    final title=titleController.text;
   final description=descriptionController.text;
   final todo=widget.todo;
   if(todo==null){
    print("You Can not Call Updated Without todo data") ;
    return;
   }
   final id=todo["_id"];
   final body={
     "title":title,
     "description":description,
     "is_completed":false,
   };
   //update to the server
    final url='https://api.nstack.in/v1/todos/$id';
    final uri= Uri.parse(url);
    final response=await http.put(uri,body: jsonEncode(body),
        headers: {'Content-Type':'application/json'}
    );
    if(response.statusCode==200)
    {
      showSuccessMessage('Updation Success');
    }
    else{
      showErrorMessage('Updation Failed');
    }
  }
  Future<void> submitData()async {
    //get the data from form
    final title=titleController.text;
    final description=descriptionController.text;
    final body={
      "title": title,
      "description": description,
      "is_completed": false
    };
    //submit data to server
      final url='https://api.nstack.in/v1/todos';
      final uri= Uri.parse(url);
      final response=await http.post(uri,body: jsonEncode(body),
        headers: {'Content-Type':'application/json'}
      );
    //show success or fail message based on status
   if(response.statusCode==201)
     {
       titleController.text='';
       descriptionController.text='';
       showSuccessMessage('Creation Success');
     }
   else{
      showErrorMessage('Creation Failed');
   }
  }
  void showSuccessMessage(String message){
    final snackBar=SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar=SnackBar(content: Text(message,style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
