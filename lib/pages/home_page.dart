import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 2),
    Band(id: '2', name: 'Pxndx', votes: 6),
    Band(id: '3', name: 'Sing with sirens', votes: 1),
    Band(id: '4', name: 'José Madero', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("BandNames", style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1 ,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTile(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction){
        setState(() => bands.removeWhere((item) => item.id == band.id));
      },
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text("Delete band", style: TextStyle(color: Colors.white),),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(band.votes.toString(), style: TextStyle(fontSize: 20)),
        onTap: (){
          print(band.name);
        },
      ),
    );
  }

  void addNewBand() async{
    final newBrandNameController = new TextEditingController();
    if(Platform.isAndroid){
      return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("New brand name:"),
            content: TextField(controller: newBrandNameController),
            actions: [
              MaterialButton(
                child: Text("Add", style: TextStyle(color: Colors.blue),),
                elevation: 5,
                onPressed: () => addBandToList(newBrandNameController.text)
              )
            ],
          );
        }
      );
    }
    return showCupertinoDialog(
      context: context,
      builder: (_){
        return CupertinoAlertDialog(
          title: Text("New brand name:"),
          content: CupertinoTextField(controller: newBrandNameController),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text("Add", style: TextStyle(color: Colors.blue),),
              onPressed: () => addBandToList(newBrandNameController.text)
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text("Dismiss", style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop()
            )
          ],
        );
      }
    );
  }

  void addBandToList(String name){
    if(name.length > 1){
      setState(() {
        this.bands.add(Band(id: name.length.toString(), name: name, votes: 0));
      });
    }
    Navigator.of(context).pop();
  }
}