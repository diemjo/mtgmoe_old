import 'package:mtgmoe/routes/settings_data.dart';
import 'package:mtgmoe/routes/settings_sets.dart';
import 'package:mtgmoe/util/settings_row.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:mtgmoe/moe_style.dart';
import 'package:mtgmoe/model/app_state_model.dart';
import 'package:mtgmoe/util/card_update.dart';

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
    print("Settings init");
  }


  @override
  void dispose() {
    print("Settings dispose");
    super.dispose();
  }

  void _updateDB() {
    var model = Provider.of<AppStateModel>(context, listen: false);
    switch(model.updateStatus) {
      case UpdateStatus.IDLE:
        model.doUpdate = true;
        model.updateFuture = updateCards(model).then((value) => value as Map<String, Object>);
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
                padding: const EdgeInsets.only(top: 20.0, left: 5.0, right: 5.0),
                child: Container(
                  height: 50,
                  child: RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          model.updateStatus == UpdateStatus.IDLE ? 'UPDATE DATABASE' : 'CANCEL UPDATE',
                          style: MoeStyle.defaultText,
                        ),
                      ],
                    ),
                    onPressed: _updateDB,
                  ),
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
              Text('Update cards from remote database'),
            ],
          ),
        );
      case UpdateStatus.INITIALIZING:
      case UpdateStatus.DOWNLOADING:
        return Container(
          height: 40.0,
          child: FutureBuilder(
            future: model.updateFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error.toString());
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(snapshot.error.toString()),
                  ],
                );
              }
              else if (snapshot.hasData) {
                var data = snapshot.data as dynamic;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data['status']=='success' ? 'Successfully updated' : data['status'] == 'cancel' ? 'Update cancelled' : 'error updating: ${data['error']}')
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
                          child: Text('Downloading cards: ${model.updateProgress}'),
                        ),
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
