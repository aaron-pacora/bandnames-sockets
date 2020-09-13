import 'dart:io';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    SocketService socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on("active-bands", handleActiveBands);
    super.initState();
  }

  void handleActiveBands(dynamic payload){
    setState(() {
      bands = (payload['bands'] as List).map((newBand) => Band.fromMap(newBand)).toList();
    });
  }

  @override
  void dispose() {
    SocketService socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SocketService socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("BandNames", style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online ? 
              Icon(Icons.check_circle, color: Colors.blue[300]) : 
              Icon(Icons.offline_bolt, color: Colors.red[300])
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTile(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewBand,
        child: Icon(Icons.add)
      ),
    );
  }

  Widget _bandTile(Band band) {
    SocketService socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) => socketService.emit('delete-band', {"band_id": band.id}),
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
        onTap: () => socketService.emit('vote-band', {"band_id": band.id}),
      ),
    );
  }

  void addNewBand() async{
    final newBrandNameController = new TextEditingController();
    if(Platform.isAndroid){
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("New brand name:"),
          content: TextField(controller: newBrandNameController),
          actions: [
            MaterialButton(
              child: Text("Add", style: TextStyle(color: Colors.blue),),
              elevation: 5,
              onPressed: () => addBandToList(newBrandNameController.text)
            )
          ],
        )
      );
    }
    return showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
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
      )
    );
  }

  void addBandToList(String name){
    if(name.length > 1){
      SocketService socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', {"name": name});
    }
    Navigator.of(context).pop();
  }

  Widget _showGraph(){
    if(bands.length == 0){
      return Container();
    }
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });
    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          decimalPlaces: 0,
          showChartValuesInPercentage: true
        ),
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          showLegends: true,
        ),
      )
    );
  }
}