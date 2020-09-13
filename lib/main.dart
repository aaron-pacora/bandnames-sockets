import 'package:band_names/pages/home_page.dart';
import 'package:band_names/pages/status_page.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService())
      ],
      child: MaterialApp(
        title: 'Material App',
        debugShowCheckedModeBanner: false,
        initialRoute: 'home_page',
        routes: {
          'home_page': (_) => HomePage(),
          'status_page': (_) => StatusPage(),
        },
      ),
    );
  }
}