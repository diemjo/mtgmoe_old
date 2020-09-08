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
      child: Column(
        children: [
          AppBar(
            title: Text('MTGMoe'),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.asset('images/moe_girl.png', fit: BoxFit.cover),
                Center(
                  child: Text('Placeholder', style: TextStyle(fontSize: 20, color: Color(0xff000000), backgroundColor: Color(0xffffffff))),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
