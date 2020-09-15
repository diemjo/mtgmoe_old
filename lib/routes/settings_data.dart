import 'package:MTGMoe/util/fs_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:MTGMoe/moe_style.dart';
import 'package:MTGMoe/util/settings_row.dart';

class SettingsManageData extends StatefulWidget {
  @override
  _SettingsManageDataState createState() => _SettingsManageDataState();
}

class _SettingsManageDataState extends State<SettingsManageData> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            primary: true,
            centerTitle: true,
            toolbarHeight: 50,
            title: Text('Manage data', style: TextStyle(color: Colors.white), softWrap: true, maxLines: 2),
            backgroundColor: MoeStyle.filterButtonColor.withAlpha(100),
          ),
          backgroundColor: MoeStyle.defaultAppColor,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: settingRow(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('CARD DATABASE', style: MoeStyle.smallText,),
                          )
                      ),
                      MaterialButton(
                        onPressed: () { _showDeleteDialog(context, deleteDatabaseData); },
                        child: Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
              settingRow(
                child: _fsSizeEntry(fsGetDatabaseSize()),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: settingRow(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('IMAGE CACHE', style: MoeStyle.smallText,),
                          )
                      ),
                      MaterialButton(
                        onPressed: () { _showDeleteDialog(context, deleteImagesData); },
                        child: Text('Clear', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
              settingRow(
                child: _fsSizeEntry(fsGetImagesSize()),
              ),
            ],
          ),
        )
    );
  }

  void _showDeleteDialog(BuildContext context, Future<void> onDelete()) {
    showDialog(
      context: context,
      builder: (context) => _confirmDeleteDialog(context, onDelete),
      barrierDismissible: false,
    );
  }

  Widget _confirmDeleteDialog(BuildContext context, Future<void> onDelete()) {
    return Dialog(
      elevation: 1,
      child: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Please confirm to delete local data', style: MoeStyle.defaultText, maxLines: 3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
                      child: RaisedButton(
                        child: Text('Cancel', style: MoeStyle.defaultBoldText),
                        onPressed: ()  {
                          Navigator.of(context).pop('Cancel');
                        },
                      ),
                    ),
                  ),
                  Divider(color: MoeStyle.dividerColor),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 5.0, left: 5.0),
                      child: RaisedButton(
                        color: MoeStyle.filterButtonColor,
                        child: Text('Delete', style: MoeStyle.defaultBoldText),
                        onPressed: () {
                          onDelete().then((value) {
                            setState(() {});
                            Navigator.of(context).pop('Delete');
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _fsSizeEntry(Future<int> future) {
  return Row(
    children: [
      Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Size', style: MoeStyle.defaultText),
          )
      ),
      FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          //print(snapshot.data);
          if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          else if (snapshot.connectionState!=ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('calculating', style: TextStyle(color: Colors.black12)),
            );
          }
          else {

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_formatFileSize(snapshot.data)),
            );
          }
        },
      )
    ],
  );
}

String _formatFileSize(int bytes) {
  num size = bytes;
  String unit = 'B';
  if (size>1000000000) {
    size = size/1000000000;
    unit = 'GB';
  }
  else if (size>1000000) {
    size = size/1000000;
    unit = 'MB';
  }
  else if (size>1000) {
    size = size/1000;
    unit = 'KB';
  }
  return '${size > 0 ? size.toStringAsFixed(2) : '0'} $unit';
}