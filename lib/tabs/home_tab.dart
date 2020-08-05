import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppBar(
        title: Text('MTGMoe'),
      ),
    );
  }
}
