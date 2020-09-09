import 'package:MTGMoe/routes/settings_sets.dart';
import 'package:MTGMoe/util/card_set_prefs.dart';
import 'package:MTGMoe/util/settings_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/mtg_db.dart';
import 'package:MTGMoe/util/card_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}
class _SettingsTabState extends State<SettingsTab> {
  Stream<Map<String, Object>> _updateStream;

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    //print("Settings init");
  }


  @override
  void dispose() {
    //print("Settings dispose");
    super.dispose();
  }

  void _updateDB() {
    var model = Provider.of<AppStateModel>(context, listen: false);
    switch(model.updateStatus) {
      case UpdateStatus.DEFAULT:
        model.doUpdate = true;
        model.updateStatus = UpdateStatus.LOADING;
        _updateStream = updateSets(model);
        break;
      case UpdateStatus.LOADING:
        model.doUpdate = false;
        model.updateStatus = UpdateStatus.CANCELLED;
        break;
      case UpdateStatus.CANCELLED:
      default:
    }
    model.update();
  }

  @override
  Widget build(BuildContext context) {
    //print("Settings build");
    return SafeArea(
      child: Consumer<AppStateModel>(
        builder: (context, model, child) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        model.updateStatus == UpdateStatus.DEFAULT ? 'Update DB' : 'Cancel Update',
                        style: MoeStyle.defaultText,
                      ),
                    ],
                  ),
                  onPressed: _updateDB,
                ),
              ),
              _buildUpdateInfo(context, model),
              Divider(color: Colors.white),
              settingRow(
                child: FlatButton(
                  onPressed: () { Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => SettingsSetTypes(setTypes: getPrefsSetTypes()),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) => SlideTransition(
                        child: child,
                        position: animation.drive(Tween(begin: Offset(1.0, 0.0), end: Offset.zero)),
                      ),
                      transitionDuration: Duration(milliseconds: 150)
                    )
                  );},
                  splashColor: Colors.transparent,
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Card set types', style: MoeStyle.defaultText),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: MoeStyle.defaultIconColor),
                    ],
                  ),
                )
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUpdateInfo(BuildContext context, AppStateModel model) {
    switch(model.updateStatus) {
      case UpdateStatus.DEFAULT:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Update cards from database'),
            ],
          ),
        );
      case UpdateStatus.CANCELLED:
      case UpdateStatus.LOADING:
        return Container(
          height: 40.0,
          child: StreamBuilder<Map<String, Object>>(
            stream: _updateStream,
            initialData: { 'set' : '_initial_data_', 'progress' : 0 },
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data['set']=='_error_') {
                print(snapshot.error);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Error Updating Sets: ${snapshot.hasError ? '': snapshot.data['error']}'),
                  ],
                );
              }
              else if (model.updateStatus == UpdateStatus.CANCELLED) {
                if (snapshot.data['set']=='_cancelled_') {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                    setState(() {
                      model.updateStatus = UpdateStatus.DEFAULT;
                    });
                  });
                }
                return Container(
                  height: 40.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Cancelling Update'),
                    ],
                  ),
                );
              }
              else if (snapshot.data['set']=='_initial_data_') {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Updating'),
                  ],
                );
              }
              else if (snapshot.data['set']!='_finished_') {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Updating: ${snapshot.data['set'] as String}'),
                    CircularProgressIndicator(value: snapshot.data['progress'] as double)
                  ],
                );
              }
              else {
                model.updateStatus = UpdateStatus.DEFAULT;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Updated sets'),
                  ],
                );
              }
            },
          )
        );
      default:
        throw Exception('invalid status');
    }
  }
}
