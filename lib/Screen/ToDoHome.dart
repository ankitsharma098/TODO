import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'AddTodo.dart';

class ToDoHome extends StatefulWidget {
  const ToDoHome({super.key});

  @override
  State<ToDoHome> createState() => _ToDoHomeState();
}

class _ToDoHomeState extends State<ToDoHome> {
  @override
  void initState() {
    fetchTodo();
  }
  @override
  bool isLoading=true;
  List items=[];

  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;

    return Scaffold(
        extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Todo List"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      floatingActionButton: Padding(
        padding:  EdgeInsets.only(left: size.width*0.08,right:size.width*0.02, ),
        child: Container(
          width: size.width*0.98,
          child: FloatingActionButton(
            backgroundColor: Colors.cyan,
            onPressed: navigateToAddPage,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left:size.width*0.02),
                  child: Image.asset("assets/images/plus.png",),
                ),
                SizedBox(width: size.width*0.05,),
                Container(
                  child: Text("Add a Task",style: TextStyle(color: Colors.deepPurpleAccent),),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: size.height*0.90,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/MainBackground.jpg'),
                  fit: BoxFit.cover
              ),
            ),
            child: Visibility(
              visible: isLoading,
              child:Center(child: CircularProgressIndicator(),),
              replacement: RefreshIndicator(
                onRefresh: fetchTodo,
                child: Visibility(
                  visible: items.isNotEmpty,
                  replacement: Center(child: Text("No Task",style: Theme.of(context).textTheme.headline3,),),
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                      itemCount: items.length,
                      itemBuilder: (context,index){
                        final item=items[index] as Map;
                        final id=item['_id'] as String;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: EdgeInsets.only(top: size.height*0.01),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(child: Text('${index+1}'),backgroundColor: Colors.white60),
                              title: Text(item['title']),
                              subtitle: Text(item['description']),
                              trailing: PopupMenuButton(
                                color: Colors.cyanAccent,
                                onSelected: (value){
                                  if(value=='edit'){
                                  navigateToEditPage(item);
                                  }
                                  else if(value=='delete'){
                                    deleteById(id);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(child: Text("Edit"),
                                  value: 'edit',),
                                  PopupMenuItem(child: Text("Delete"),
                                  value: 'delete',),

                                ];
                              },),
                            ),
                            Divider(height: size.height*0.005,color: Colors.black54,)
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Container(
            height: size.height*0.10,
            decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/MainBackground.jpg'),
                fit: BoxFit.cover
            ),
          ),),
        ],
      )
    );
  }
  Future<void> navigateToEditPage(Map item) async{
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTodo(todo: item,)));
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }
  Future<void> navigateToAddPage() async{
    await Navigator.push(context, MaterialPageRoute(builder: (context)=>AddTodo()));
    setState(() {
      isLoading=true;
    });
    fetchTodo();
  }
  Future<void> deleteById(String id) async{
      final url='https://api.nstack.in/v1/todos/$id';
      final uri=Uri.parse(url);
      final response=await http.delete(uri);
      if(response.statusCode==200){
        final filtered=items.where((element)=>element['_id'] !=id).toList();
        setState(() {
          items=filtered;
        });
      }
      else{
        showErrorMessage('Deletion Failed ');

      }


  }
  Future<void> fetchTodo() async{
    final url="https://api.nstack.in/v1/todos?page=1&limit=10";
    final uri=Uri.parse(url);
    final response=await http.get(uri);
    if(response.statusCode==200){
     final json=jsonDecode(response.body) as Map;
     final result=json['items'] as List;
     setState(() {
        items=result;
     });
    }
    setState(() {
      isLoading=false;
    });

  }

  void showErrorMessage(String message){
    final snackBar=SnackBar(content: Text(message,style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
