import 'package:MTGMoe/routes/settings_data.dart';
import 'package:MTGMoe/routes/settings_sets.dart';
import 'package:MTGMoe/util/settings_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/model/app_state_model.dart';
import 'package:MTGMoe/util/card_update.dart';

class SettingsTab extends StatefulWidget {
  @override
  _SettingsTabState createState() => _SettingsTabState();
}
class _SettingsTabState extends State<SettingsTab> {

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
      case UpdateStatus.IDLE:
        model.doUpdate = true;
        model.updateFuture = updateCards(model);
        break;
      default:
        model.updateStatus = UpdateStatus.IDLE;
        model.doUpdate = false;
        model.cancelToken?.cancel();
        model.cancelToken = null;
        model.updateFuture = null;
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
                        model.updateStatus == UpdateStatus.IDLE ? 'Update DB' : 'Cancel Update',
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
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) => SettingsSetTypes())
                    );
                  },
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
                ),
                top: true,
              ),
              settingRow(
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          CupertinoPageRoute(builder: (context) => SettingsManageData())
                      );
                    },
                    splashColor: Colors.transparent,
                    padding: const EdgeInsets.all(0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Manage local data', style: MoeStyle.defaultText),
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
      case UpdateStatus.IDLE:
        return Container(
          height: 40.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Update cards from database'),
            ],
          ),
        );
      case UpdateStatus.INITIALIZING:
      case UpdateStatus.DOWNLOADING:
      case UpdateStatus.STORING:
        return Container(
          height: 40.0,
          child: FutureBuilder(
            future: model.updateFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.error),
                  ],
                );
              }
              else if (snapshot.hasData) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.data['status']=='success' ? 'Successfully updated' : snapshot.data['status'] == 'cancel' ? 'Update cancelled' : 'error updating: ${snapshot.data['error']}')
                  ],
                );
              }
              else {
                switch (model.updateStatus) {
                  case UpdateStatus.INITIALIZING:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Initializing')
                      ],
                    );
                  case UpdateStatus.DOWNLOADING:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Downloading'),
                        ),
                        CircularProgressIndicator(value: model.updateProgress/100),
                      ],
                    );
                  case UpdateStatus.STORING:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Storing'),
                        ),
                        CircularProgressIndicator(value: model.updateProgress/100),
                      ],
                    );
                  default:
                    return Container();
                }
              }
            },
          )
        );
      default:
        throw Exception('invalid status');
    }
  }
}
