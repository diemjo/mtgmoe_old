import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/util/card_set_prefs.dart';
import 'package:MTGMoe/util/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsSetTypes extends StatefulWidget {
  @override
  _SettingsSetTypesState createState() => _SettingsSetTypesState();
}

class _SettingsSetTypesState extends State<SettingsSetTypes> {
  Future<Map<String, bool>> setTypes;

  _SettingsSetTypesState() {
    setTypes =  getPrefsSetTypes();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            primary: true,
            centerTitle: true,
            toolbarHeight: 50,
            title: Text('Set Types', style: TextStyle(color: Colors.white), softWrap: true, maxLines: 2),
            backgroundColor: MoeStyle.filterButtonColor.withAlpha(100),
          ),
          backgroundColor: MoeStyle.defaultAppColor,
          body: FutureBuilder(
            future: setTypes,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Error loading set preferences: ${snapshot.error}'),
                );
              }
              else if (snapshot.connectionState==ConnectionState.waiting) {
                return Container();
              }
              else if (snapshot.connectionState==ConnectionState.done){
                return _buildSetTypeSettings(snapshot.data);
              }
              else {
                print(snapshot.connectionState);
                return Container();
              }
            },
          ),
        )
    );
  }

  Widget _buildSetTypeSettings(Map<String, bool> map) {
    return CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((context, _index) {
              if (_index==0) {
                return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text('SELECT SETS TO DISPLAY', style: MoeStyle.smallText),
                    )
                );
              }
              if (map.length==0 && _index==1) {
                  return Text('No sets downloaded yet.\nUpdate Database to select set types', style: MoeStyle.defaultText);
              }
              int index = _index-1;
              if (index < map.keys.length) {
                String name = map.keys.elementAt(index);
                bool enabled = map.values.elementAt(index);
                return settingRow(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(name.replaceAll('_', ' '), style: MoeStyle.defaultText),
                        )
                      ),
                      Container(
                        width: 60,
                        height: 40,
                        child: PlatformSwitch(
                          value: enabled,
                          onChanged: (value) {
                            SharedPreferences.getInstance().then((sp) => setState((){ setPrefsSetType(name, value); map[name]=value; }));
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
              else {
                return null;
              }
            }),
          )
        ]
    );
  }

}
